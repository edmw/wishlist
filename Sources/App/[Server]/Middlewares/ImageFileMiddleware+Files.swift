import Vapor
import Crypto

import Library

extension ImageFileMiddleware {

    /// Lists all regular files in Images directory and returns a `ImageFileLocator` per file.
    /// To avoid race conditions a date can be specified which must be after the creation date of
    /// file file to be returned. Files neither being regular nor matching the date will be omitted.
    /// - Parameter createdBefore: Files must be created before this date to be returned.
    /// Note: Any files which can not be represented by a valid `ImageFileLocator` will be silently
    /// omitted.
    func listFiles(createdBefore: Date?) -> [ImageFileLocator] {
        if let directoryEnumerator = directoryEnumerator {
            return directoryEnumerator
                .lazy
                .compactMap { object in
                    guard let fileURL = object as? URL else {
                        return nil
                    }
                    if let createdBefore = createdBefore {
                        let fileCreated = fileURL.creationDate
                        guard fileCreated < createdBefore else {
                            return nil
                        }
                    }
                    return fileURL.isRegularFile ? try? imageFileLocator(from: fileURL) : nil
                }
        }
        return []
    }

    func fileExists(
        at imageFileLocator: ImageFileLocator,
        on container: Container
    ) throws -> Bool {
        let fileManager = FileManager.default
        let fileURL = imageFileLocator.absoluteURL
        return try fileManager.fileExists(
            at: fileURL,
            in: self.imagesDirectoryURL
        )
    }

    func removeFile(
        at imageFileLocator: ImageFileLocator,
        deleteParentsIfEmpty: Bool = false,
        on container: Container
    ) throws {
        let fileManager = FileManager.default
        let fileURL = imageFileLocator.absoluteURL
        do {
            try fileManager.removeFile(
                at: fileURL,
                in: self.imagesDirectoryURL
            )
            if deleteParentsIfEmpty {
                try fileManager.removeDirectories(
                    at: fileURL.deletingLastPathComponent(),
                    in: self.imagesDirectoryURL
                )
            }
        }
        catch {
            container.requireLogger().warning(
                "Error while removing file '\(fileURL)': \(error)"
            )
        }
    }

    func purgeDirectories(on container: Container) {
        let fileManager = FileManager.default
        let fileDirectoryURL = self.imagesDirectoryURL
        do {
            if let directoryEnumerator = directoryEnumerator {
                try directoryEnumerator.forEach { object in
                    guard let fileURL = object as? URL else {
                        return
                    }
                    if fileURL.isDirectory {
                        if try contentsOfDirectory(at: fileURL).isEmpty {
                            try fileManager.removeDirectory(
                                at: fileURL,
                                in: self.imagesDirectoryURL
                            )
                        }
                    }
                }
            }
        }
        catch {
            container.requireLogger().warning(
                "Error while purging directories '\(fileDirectoryURL)': \(error)"
            )
        }

    }

    // MARK: -

    private var directoryEnumerator: FileManager.DirectoryEnumerator? {
        return FileManager.default
            .enumerator(
                at: self.imagesDirectoryURL,
                includingPropertiesForKeys: [
                    .creationDateKey,
                    .isRegularFileKey,
                    .isDirectoryKey
                ],
                options: [ .skipsHiddenFiles ]
            )
    }

    private func contentsOfDirectory(at url: URL) throws -> [URL] {
        return try FileManager.default
            .contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [],
                options: []
            )
    }
}
