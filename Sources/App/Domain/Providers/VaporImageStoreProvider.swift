import Domain

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

    func storeImage(for imagable: Imageable, from url: URL) throws -> EventLoopFuture<URL?> {
        return try request.make(ImageFileMiddleware.self)
            .upload(
                from: url,
                width: imagable.imageableSize.width,
                height: imagable.imageableSize.height,
                key: requireKey(for: imagable),
                groupkey: requireGroupKey(for: imagable),
                on: request
            )
    }

    func removeImages(for imagable: Imageable) throws {
        try request.make(ImageFileMiddleware.self)
            .removeAll(
                key: requireKey(for: imagable),
                groupkey: requireGroupKey(for: imagable),
                deleteDirectory: true,
                on: request
            )
    }

    private func requireKey(for imagable: Imageable) throws -> String {
        guard let key = imagable.imageableEntityKey else {
            throw ImageableError.keyMissing(\Imageable.imageableEntityKey)
        }
        let validCharactersForImageableKey
            = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        guard validCharactersForImageableKey.isSuperset(
            of: CharacterSet(charactersIn: key)
        ) else {
            throw ImageableError.keyInvalid(\Imageable.imageableEntityKey)
        }
        return key
    }

    private func requireGroupKey(for imagable: Imageable) throws -> String {
        guard let groupkey = imagable.imageableEntityGroupKey else {
            throw ImageableError.keyMissing(\Imageable.imageableEntityGroupKey)
        }
        let validCharactersForImageableGroupKey
            = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        guard validCharactersForImageableGroupKey.isSuperset(
            of: CharacterSet(charactersIn: groupkey)
        ) else {
            throw ImageableError.keyInvalid(\Imageable.imageableEntityGroupKey)
        }
        return groupkey
    }

}
