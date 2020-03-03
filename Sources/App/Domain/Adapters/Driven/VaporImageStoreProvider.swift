import Domain
import Library

import Vapor

// MARK: VaporImageStoreProvider

/// Adapter for the domain layers `ImageStoreProvider` to be used with Vapor.
///
/// This delegates the storage of images to the web app‘s image file middleware.
struct VaporImageStoreProvider: ImageStoreProvider {

    let request: Request

    init(on request: Request) {
        self.request = request
    }

    func storeImage(for imagable: Imageable, from url: URL)
        throws -> EventLoopFuture<ImageStoreLocator?>
    {
        let imageFileMiddleware = try request.make(ImageFileMiddleware.self)
        return try imageFileMiddleware
            .uploadImage(
                from: url,
                width: imagable.imageableSize.width,
                height: imagable.imageableSize.height,
                key: requireKey(for: imagable),
                groupkeys: requireGroupKeys(for: imagable),
                on: request
            )
            .map { imagefilelocator in
                guard let url = imagefilelocator?.url else {
                    return nil
                }
                return ImageStoreLocator(url)
            }
    }

    func removeImages(for imagable: Imageable) throws {
        let imageFileMiddleware = try request.make(ImageFileMiddleware.self)
        try imageFileMiddleware.removeImages(
            key: requireKey(for: imagable),
            groupkeys: requireGroupKeys(for: imagable),
            deleteParentsIfEmpty: true,
            on: request
        )
    }

    func removeImage(at locator: ImageStoreLocator) throws {
        let imageFileMiddleware = try request.make(ImageFileMiddleware.self)
        if let imageFileLocator = imageFileMiddleware.imageFileLocator(from: locator.url) {
            try imageFileMiddleware.removeFile(
                at: imageFileLocator,
                deleteParentsIfEmpty: true,
                on: request
            )
        }
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

    // MARK: CleanupJob

    final class CleanupJob: DispatchableJob<Bool> {

        override func run(_ context: JobContext) -> EventLoopFuture<Bool> {
            let container = context.container
            do {
                let itemRepository: ItemRepository = try container.make()
                return itemRepository.all().map { items in
                    // collect local image urls from all items into a bloom filter
                    var bloomfilter = BloomFilter<String>(expectedNumberOfElements: items.count)
                    for item in items {
                        guard let localimageurl = item.localImageURL else {
                            continue
                        }
                        bloomfilter.insert(localimageurl.absoluteString)
                    }
                    // iterate local file urls for images
                    let now = Date()
                    let imageFileMiddleware: ImageFileMiddleware = try container.make()
                    for imagefilelocator in imageFileMiddleware.listFiles(createdBefore: now) {
                        // if a image file url is not contained in the bloom filter the image is
                        // definitely not used for an item, so it is save to delete
                        let imagestorelocator = ImageStoreLocator(imagefilelocator.url)
                        if bloomfilter.containsNot(imagestorelocator.absoluteString) {
                            try imageFileMiddleware.removeFile(
                                at: imagefilelocator,
                                deleteParentsIfEmpty: true,
                                on: container
                            )
                            container.logger?.debug("ImagesCleanupJob: delete \(imagestorelocator)")
                        }
                    }
                    imageFileMiddleware.purgeDirectories(on: container)
                    return true
                }
            }
            catch {
                container.logger?.error("ImagesCleanupJob failed with \(error)")
            }
            return container.future(false)
        }

        // MARK: CustomStringConvertible

        override var description: String {
            return "ImagesCleanupJob(at: \(scheduled))"
        }

    }

}
