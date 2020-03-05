import Domain
import Library

import Vapor

// MARK: VaporImageStoreProvider

/// Adapter for the domain layers `ImageStoreProvider` to be used with Vapor.
///
/// This delegates the storage of images to the web app‘s image file middleware.
struct VaporImageStoreProvider: ImageStoreProvider {

    let container: Container

    init(on container: Container) {
        self.container = container
    }

    func storeImage(for imagable: Imageable, from url: URL)
        throws -> EventLoopFuture<ImageStoreLocator?>
    {
        let imageFileMiddleware = try container.make(ImageFileMiddleware.self)
        return try imageFileMiddleware
            .uploadImage(
                from: url,
                width: imagable.imageableSize.width,
                height: imagable.imageableSize.height,
                key: requireKey(for: imagable),
                groupkeys: requireGroupKeys(for: imagable),
                on: container
            )
            .map { imagefilelocator in imagefilelocator.flatMap(ImageStoreLocator.init) }
    }

    func removeImages(for imagable: Imageable) throws {
        let imageFileMiddleware = try container.make(ImageFileMiddleware.self)
        try imageFileMiddleware.removeImages(
            key: requireKey(for: imagable),
            groupkeys: requireGroupKeys(for: imagable),
            deleteParentsIfEmpty: true,
            on: container
        )
    }

    func removeImage(at locator: ImageStoreLocator) throws {
        let imageFileMiddleware = try container.make(ImageFileMiddleware.self)
        let imageFileLocator = try imageFileMiddleware.imageFileLocator(from: locator.url)
        try imageFileMiddleware.removeFile(
            at: imageFileLocator,
            deleteParentsIfEmpty: true,
            on: container
        )
    }

    private static let validCharactersForImageableKey
        = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))

    private func requireKey(for imagable: Imageable) throws -> String {
        guard let key = imagable.imageableEntityKey else {
            throw ImageableError.keyMissing(\Imageable.imageableEntityKey)
        }
        guard VaporImageStoreProvider.validCharactersForImageableKey.isSuperset(
            of: CharacterSet(charactersIn: key)
        ) else {
            throw ImageableError.keyInvalid(\Imageable.imageableEntityKey)
        }
        return key
    }

    private static let validCharactersForImageableGroupKey
        = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))

    private func requireGroupKeys(for imagable: Imageable) throws -> [String] {
        guard let groupkeys = imagable.imageableEntityGroupKeys else {
            throw ImageableError.keyMissing(\Imageable.imageableEntityGroupKeys)
        }
        for groupkey in groupkeys {
            guard VaporImageStoreProvider.validCharactersForImageableGroupKey.isSuperset(
                of: CharacterSet(charactersIn: groupkey)
            ) else {
                throw ImageableError.keyInvalid(\Imageable.imageableEntityGroupKeys)
            }
        }
        return groupkeys
    }

    // MARK: CleanUpJob

    final class CleanUpJob: DispatchableJob<Bool> {

        override func work(_ context: JobContext) -> EventLoopFuture<Bool> {
            let container = context.container
            let logger = container.requireLogger().technical
            do {
                let jobService = try container.make(DispatchingService.self)
                return
                    try jobService.execute(DisposeJob(on: container), in: context)
                .flatMap {
                    try jobService.execute(RecoverJob(on: container), in: context)
                }
                .transform(to: true)

            }
            catch {
                logger.error("\(self) failed with \(error)")
            }
            return container.future(false)
        }

        // CustomStringConvertible

        override var description: String {
            return "ImagesCleanUpJob(scheduled: \(scheduled))"
        }

    }

    // MARK: DisposeJob

    final class DisposeJob: DispatchableJob<Bool> {

        override func work(_ context: JobContext) -> EventLoopFuture<Bool> {
            let container = context.container
            let logger = container.requireLogger().technical
            logger.info("\(self) running")
            do {
                let itemRepository: ItemRepository = try container.make()
                return itemRepository.all().map { items in
                    // collect local image urls from all items into a bloom filter
                    var bloomfilter = BloomFilter<String>(expectedNumberOfElements: items.count)
                    for item in items {
                        guard let imagestorelocator = item.localImageURL else {
                            continue
                        }
                        bloomfilter.insert(imagestorelocator.absoluteString)
                    }
                    // iterate local file urls for images
                    let now = Date()
                    let imageFileMiddleware: ImageFileMiddleware = try container.make()
                    for imagefilelocator in imageFileMiddleware.listFiles(createdBefore: now) {
                        // if a image file url is not contained in the bloom filter the image is
                        // definitely not used for an item, so it is save to delete
                        let imagestorelocator = ImageStoreLocator(imagefilelocator)
                        if bloomfilter.containsNot(imagestorelocator.absoluteString) {
                            // remove image
                            logger.info(
                                "\(self): process image \(imagestorelocator)"
                            )
                            try imageFileMiddleware.removeFile(
                                at: imagefilelocator,
                                deleteParentsIfEmpty: true,
                                on: container
                            )
                        }
                    }
                    imageFileMiddleware.purgeDirectories(on: container)
                    return true
                }
            }
            catch {
                logger.error("\(self) failed with \(error)")
            }
            return container.future(false)
        }

        // CustomStringConvertible

        override var description: String {
            return "ImagesDisposeJob"
        }

    }

    // MARK: RecoverJob

    final class RecoverJob: DispatchableJob<Bool> {

        let userItemsActor: UserItemsActor

        let imageFileMiddleware: ImageFileMiddleware

        let imageStoreProvider: ImageStoreProvider

        let logger: Logger

        override init(
            on container: Container,
            at date: Date = Date(),
            before deadline: Date = .distantFuture
        ) throws {
            self.userItemsActor = try container.make()
            self.imageFileMiddleware = try container.make()
            self.imageStoreProvider = VaporImageStoreProvider(on: container)
            self.logger = container.requireLogger().technical
            try super.init(on: container, at: date, before: deadline)
        }

        override func work(_ context: JobContext) -> EventLoopFuture<Bool> {
            let worker = context.eventLoop
            let container = context.container
            let logger = container.requireLogger().technical
            logger.info("\(self) running")
            do {
                let itemRepository: ItemRepository = try container.make()
                return itemRepository.all().flatMap { items in
                    let results = try items.compactMap { item in
                        try self.recover(item: item, on: container, worker: worker)
                    }
                    return results.flatten(on: worker).transform(to: true)
                }
            }
            catch {
                logger.error("\(self) failed with \(error)")
            }
            return container.future(false)
        }

        private func recover(
            item: Item,
            on container: Container,
            worker: EventLoop
        ) throws -> EventLoopFuture<Void>? {
            guard item.imageURL != nil else {
                logger.debug("\(self): skipping \(item) [noimage]")
                return nil
            }
            guard let itemid = item.id else {
                logger.debug("\(self): skipping \(item) [noid]")
                return nil
            }
            if let imagestorelocator = item.localImageURL {
                // check if an image is already stored
                let imagefilelocator = try imageFileMiddleware.imageFileLocator(
                    from: imagestorelocator.url,
                    isRelative: true
                )
                if try imageFileMiddleware.fileExists(at: imagefilelocator, on: container) {
                    logger.debug("\(self): skipping \(item) [exists]")
                    return nil
                }
            }
            // setup image
            logger.info("\(self): process \(item)")
            return try userItemsActor.setupItem(
                .specification(itemBy: itemid),
                .boundaries(worker: worker, imageStore: imageStoreProvider)
            )
            .map { result in
                let imagestorelocator = result.item.localImageURL
                self.logger.info(
                    "\(self): processed \(item) -> \(imagestorelocator ??? "nolocator")"
                )
            }
        }

        // CustomStringConvertible

        override var description: String {
            return "ImagesRecoverJob"
        }

    }

}

// MARK: -

// Mapping from `ImageFileLocator` to `ImageStoreLocator`
extension ImageStoreLocator {

    init(_ imageFileLocator: ImageFileLocator) {
        self.init(url: imageFileLocator.url)
    }

}
