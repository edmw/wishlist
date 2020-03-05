import Vapor
import Crypto

import Library

// MARK: ImageFileMiddleware

final class ImageFileMiddleware: Middleware, ServiceType {

    let imagesPath: String

    let imagesDirectory: String
    let imagesDirectoryURL: URL

    let fileManager: FileManager

    /// Initializes a ImageFileMiddleware with the specified path in the image urls and
    /// the specified directory containing the images to handle.
    /// Must be absolute paths!
    init(path: String, directory: String) {
        self.imagesPath = path.hasSuffix("/") ? path : path + "/"
        self.imagesDirectory = directory.hasSuffix("/") ? directory : directory + "/"
        self.imagesDirectoryURL = URL(fileURLWithPath: imagesDirectory, isDirectory: true)
        self.fileManager = FileManager.default
    }

    func respond(to request: Request, chainingTo next: Responder) throws
        -> EventLoopFuture<Response>
    {
        var path = request.http.url.path

        guard path.hasPrefix(self.imagesPath) else {
            return try next.respond(to: request)
        }
        path = String(path.dropFirst(self.imagesPath.count))

        guard !path.hasPrefix("/")
           && !path.contains("../")
        else {
            throw Abort(.forbidden)
        }

        let filePath = imagesDirectory + path

        guard self.fileManager.itemExistsAndIsFile(atPath: filePath) else {
            return try next.respond(to: request)
        }

        return try request.streamFile(at: filePath)
    }

    // MARK: -

    static let supportedMediaTypes
        = [ "jpeg", "png" ]

    func imageFileLocator(from url: URL, isRelative: Bool = false) throws -> ImageFileLocator {
        if isRelative {
            return try ImageFileLocator(relativeURL: url, baseURL: self.imagesDirectoryURL)
        }
        else {
            return try ImageFileLocator(absoluteURL: url, baseURL: self.imagesDirectoryURL)
        }
    }

    func uploadImage(
        from url: URL,
        width: Int,
        height: Int,
        key: String,
        groupkeys: [String],
        on container: Container
    ) throws -> EventLoopFuture<ImageFileLocator?> {

        let fileName = try SHA1.hash(url.absoluteString).base32EncodedString()

        let fileDirectoryURL = try buildDirectory(for: key, and: groupkeys, create: true)
        guard fileDirectoryURL.hasPrefix(self.imagesDirectoryURL) else {
            throw ImageFileMiddlewareError.invalidFileURL(fileDirectoryURL)
        }

        guard try imageExists(name: fileName, in: fileDirectoryURL) == false else {
            return container.future(nil)
        }

        return try container.imageProxy()
            .get(
                url: url,
                width: width,
                height: height,
                on: container
            )
            .flatMap { response in
                guard response.http.status == .ok else {
                    container.requireLogger().error(
                        "Image proxy returned non-ok status \(response.http.status)"
                    )
                    return container.future(error: Abort(response.http.status))
                }

                guard let contentType = response.http.contentType,
                      contentType.type == "image",
                      ImageFileMiddleware.supportedMediaTypes.contains(contentType.subType)
                    else {
                        return container.future(error: Abort(.unsupportedMediaType))
                    }

                let fileExtension = contentType.subType

                let fileURL = URL(
                    fileURLWithPath: "\(fileName).\(fileExtension)",
                    relativeTo: fileDirectoryURL
                )

                let imagefileurl = try self.imageFileLocator(from: fileURL)
                return try self.writeData(from: response, to: fileURL, on: container)
                    .transform(to: imagefileurl)
            }

    }

    func removeImages(
        key: String,
        groupkeys: [String],
        deleteParentsIfEmpty: Bool = false,
        on container: Container
    ) throws {
        let fileDirectoryURL = try buildDirectory(for: key, and: groupkeys)
        guard fileDirectoryURL.hasPrefix(self.imagesDirectoryURL) else {
            throw ImageFileMiddlewareError.invalidFileURL(fileDirectoryURL)
        }
        do {
            try self.fileManager.removeFiles(
                at: fileDirectoryURL,
                in: self.imagesDirectoryURL,
                extensions: ImageFileMiddleware.supportedMediaTypes
            )
            if deleteParentsIfEmpty {
                try self.fileManager.removeDirectories(
                    at: fileDirectoryURL,
                    in: self.imagesDirectoryURL
                )
            }
        }
        catch {
            container.requireLogger().warning(
                "Error while removing all files from directory '\(fileDirectoryURL)': \(error)"
            )
        }
    }

    // MARK: -

    /// Builds a directory URL for the specified keys within the images directory. When
    /// specified creates the directory if it does not exist.
    private func buildDirectory(for key: String, and groupkeys: [String], create: Bool = false)
        throws -> URL
    {
        let fileGroupDirectoryURL = URL(
            fileURLWithPath: groupkeys.joined(separator: "/"),
            isDirectory: true,
            relativeTo: self.imagesDirectoryURL
        )
        if create && !self.fileManager.fileExists(atPath: fileGroupDirectoryURL.path) {
            try self.fileManager.createDirectory(
                at: fileGroupDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        let fileDirectoryURL = URL(
            fileURLWithPath: "\(key)/",
            isDirectory: true,
            relativeTo: fileGroupDirectoryURL
        )
        if create && !self.fileManager.fileExists(atPath: fileDirectoryURL.path) {
            try self.fileManager.createDirectory(
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
        return try self.fileManager
            .contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [],
                options: [ .skipsHiddenFiles ]
            )
            .filter {
                $0.deletingPathExtension().lastPathComponent == name
            }
            .isNotEmpty
    }

    /// Writes the data from the response’s body to the specified file URL.
    /// The given file URL must point to a file inside the images directory.
    private func writeData(from response: Response, to url: URL, on container: Container) throws
        -> EventLoopFuture<Bool>
    {
        if try self.fileManager.createFile(
            at: url,
            in: self.imagesDirectoryURL,
            permissions: 0o664
        ) {
            return response.http.body.consumeData(max: 2_000_000, on: container).map { data in
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
        else {
            throw ImageFileMiddlewareError.invalidFileURL(url)
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
