import Vapor

extension Imageable {

    private func requireKey() throws -> String {
        guard let key = imageableEntityKey else {
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

    private func requireGroupKey() throws -> String {
        guard let groupkey = imageableEntityGroupKey else {
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

    func uploadImage(from url: URL, on request: Request) throws
        -> EventLoopFuture<URL?>
    {
        return try request.make(ImageFileMiddleware.self)
            .upload(
                from: url,
                width: imageableSize.width,
                height: imageableSize.height,
                key: requireKey(),
                groupkey: requireGroupKey(),
                on: request
            )
    }

    func removeImages(on request: Request) throws {
        try request.make(ImageFileMiddleware.self)
            .removeAll(
                key: requireKey(),
                groupkey: requireGroupKey(),
                deleteDirectory: true,
                on: request
            )
    }

}
