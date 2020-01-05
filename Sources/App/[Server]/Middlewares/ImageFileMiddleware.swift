import Vapor
import Crypto

final class ImageFileMiddleware: Middleware, ServiceType {

    private let imagesPath: String

    private let imagesDirectory: String
    private let imagesDirectoryURL: URL

    /// Initializes a ImageFileMiddleware with the specified path in the image urls and
    /// the specified directory containing the images to handle.
    /// Must be absolute paths!
    init(path: String, directory: String) {
        self.imagesPath = path.hasSuffix("/") ? path : path + "/"
        self.imagesDirectory = directory.hasSuffix("/") ? directory : directory + "/"
        self.imagesDirectoryURL = URL(fileURLWithPath: imagesDirectory)
    }

    func respond(to request: Request, chainingTo next: Responder) throws
        -> EventLoopFuture<Response>
    {
        var path = request.http.url.path

        guard path.hasPrefix(self.imagesPath) else {
            return try next.respond(to: request)
        }
        path = String(path.dropFirst(self.imagesPath.count))

        guard !path.hasPrefix("/") else {
            throw Abort(.forbidden)
        }
        guard !path.contains("../") else {
            throw Abort(.forbidden)
        }

        let filePath = imagesDirectory + path

        var isDir: ObjCBool = false
        guard FileManager.default
            .fileExists(atPath: filePath, isDirectory: &isDir), !isDir.boolValue else {
                return try next.respond(to: request)
        }

        return try request.streamFile(at: filePath)
    }

    static let supportedMediaTypes
        = [ "jpeg", "png" ]

    func upload(
        from url: URL,
        width: Int,
        height: Int,
        key: String,
        groupkey: String,
        on request: Request
    ) throws -> EventLoopFuture<URL?> {

        let fileName = try SHA1.hash(url.absoluteString).base32EncodedString()

        let fileDirectoryURL = try buildDirectory(for: key, and: groupkey, create: true)

        guard try imageExists(name: fileName, in: fileDirectoryURL) == false else {
            return request.future(nil)
        }

        return try request.imageProxy()
            .get(
                url: url,
                width: width,
                height: height,
                on: request
            )
            .flatMap { response in
                guard response.http.status == .ok else {
                    request.requireLogger().error(
                        "Image proxy returned non-ok status \(response.http.status)"
                    )
                    return request.future(error: Abort(response.http.status))
                }

                guard let contentType = response.http.contentType,
                      contentType.type == "image",
                      ImageFileMiddleware.supportedMediaTypes.contains(contentType.subType)
                    else {
                        return request.future(error: Abort(.unsupportedMediaType))
                    }

                let fileExtension = contentType.subType

                let fileURL = URL(
                    fileURLWithPath: "\(fileName).\(fileExtension)",
                    relativeTo: fileDirectoryURL
                )

                let filePath = fileURL.path

                guard filePath.hasPrefix(self.imagesDirectory),
                      let url = URL(string: String(filePath.dropFirst(self.imagesDirectory.count)))
                    else {
                        return request.future(error: Abort(.internalServerError))
                    }

                return try self.writeData(from: response, to: fileURL, on: request)
                    .transform(to: url)
            }

    }

    func removeAll(
        key: String,
        groupkey: String,
        deleteDirectory: Bool = false,
        on request: Request
    ) throws {

        let fileDirectoryURL = try buildDirectory(for: key, and: groupkey)

        do {
            let fileManager = FileManager.default

            try fileManager
                .contentsOfDirectory(
                    at: fileDirectoryURL,
                    includingPropertiesForKeys: [],
                    options: [ .skipsHiddenFiles ]
// FIXME: not implemented yet for linux: https://github.com/apple/swift-corelibs-foundation/pull/1548
                )
                .filter {
                    ImageFileMiddleware.supportedMediaTypes
                        .contains($0.pathExtension.lowercased())
                }
                .forEach {
                    try fileManager.removeItem(at: $0)
                }

            if deleteDirectory {
                if try fileManager
                    .contentsOfDirectory(
                        at: fileDirectoryURL,
                        includingPropertiesForKeys: []
                    ).isEmpty {
                        try fileManager.removeItem(at: fileDirectoryURL)

                        let fileGroupDirectoryURL = fileDirectoryURL.deletingLastPathComponent()
                        if try fileManager
                            .contentsOfDirectory(
                                at: fileGroupDirectoryURL,
                                includingPropertiesForKeys: []
                            ).isEmpty {
                            try fileManager.removeItem(at: fileGroupDirectoryURL)
                        }
                }
            }
        }
        catch {
            request.requireLogger().warning(
                "Error while removing all files from directory '\(fileDirectoryURL)': \(error)"
            )
        }
    }

    /// Builds a directory URL for the specified keys within the images directory. When
    /// specified creates the directory if it does not exist.
    private func buildDirectory(for key: String, and groupkey: String, create: Bool = false)
        throws -> URL
    {
        let fileGroupDirectoryURL = URL(
            fileURLWithPath: "\(groupkey)",
            isDirectory: true,
            relativeTo: self.imagesDirectoryURL
        )
        if create && !FileManager.default.fileExists(atPath: fileGroupDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: fileGroupDirectoryURL,
                withIntermediateDirectories: false,
                attributes: nil
            )
        }
        let fileDirectoryURL = URL(
            fileURLWithPath: "\(key)/",
            isDirectory: true,
            relativeTo: fileGroupDirectoryURL
        )
        if create && !FileManager.default.fileExists(atPath: fileDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: fileDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return fileDirectoryURL
    }

    /// Checks if an image with the specified name does exist in the specified directory.
    /// The given name is meant to have no path extension. 
    private func imageExists(name: String, in directory: URL) throws -> Bool {
        return try FileManager.default
            .contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [],
                options: [ .skipsHiddenFiles ]
// FIXME: not implemented yet for linux: https://github.com/apple/swift-corelibs-foundation/pull/1548
            )
            .filter {
                $0.deletingPathExtension().lastPathComponent == name
            }
            .isNotEmpty
    }

    /// Writes the data from the response’s body to the specified file URL.
    /// The given file URL must point to a file inside the images directory.
    private func writeData(from response: Response, to url: URL, on request: Request) throws
        -> EventLoopFuture<Bool>
    {
        guard url.isFileURL && url.path.hasPrefix(self.imagesDirectoryURL.path) else {
            throw ImageFileMiddlewareError.invalidFileURL(url)
        }
        FileManager.default.createFile(
            atPath: url.path,
            contents: nil,
            attributes: [ .posixPermissions: 0o664 ]
        )
        return response.http.body.consumeData(max: 2_000_000, on: request).map { data in
            if let fileHandle = FileHandle(forWritingAtPath: url.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
            return true
        }
    }

    // MARK: ServiceType

    static var serviceSupports: [Any.Type] {
        return [ImageFileMiddleware.self]
    }

    static func makeService(for container: Container) throws
        -> ImageFileMiddleware
    {
        let workDir = try container.make(DirectoryConfig.self).workDir
        return .init(
            path: "/public-images/",
            directory: workDir + "Public-Images/"
        )
    }

}
