///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - FileManager+
//
// Copyright (c) 2019-2020 Michael Baumgärtner
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation

// MARK: FileManager

extension FileManager {

    /// Creates a file. Succeeds if the file is contained in the specified directory, only.
    public func createFile(
        at targetURL: URL,
        in containerURL: URL,
        permissions: Int16 = 0o664
    ) throws -> Bool {
        guard targetURL.isFileURL else {
            throw FileManagerError.invalidScheme(targetURL)
        }
        guard containerURL.isFileURL else {
            throw FileManagerError.invalidScheme(containerURL)
        }

        let url = targetURL

        guard url.hasPrefix(containerURL) else {
            return false
        }

        return createFile(
            atPath: url.path,
            contents: nil,
            attributes: [ .posixPermissions: permissions ]
        )
    }

    /// Removes a file. Succeeds if the file is contained in the specified directory, only.
    public func removeFile(
        at targetURL: URL,
        in containerURL: URL
    ) throws {
        guard targetURL.isFileURL else {
            throw FileManagerError.invalidScheme(targetURL)
        }
        guard containerURL.isFileURL else {
            throw FileManagerError.invalidScheme(containerURL)
        }

        let url = targetURL

        guard url.hasPrefix(containerURL) else {
            throw FileManagerError.invalidURL(url)
        }

        let path = url.path
        if fileExists(atPath: path) {
            try removeItem(atPath: path)
        }
    }

    /// Removes all files in a directory. Optional deletes the files with the specified extensions,
    /// only. Directory must be contained in the specified directory.
    public func removeFiles(
        at targetURL: URL,
        in containerURL: URL,
        extensions: [String] = []
    ) throws {
        guard targetURL.isFileURL else {
            throw FileManagerError.invalidScheme(targetURL)
        }
        guard containerURL.isFileURL else {
            throw FileManagerError.invalidScheme(containerURL)
        }

        let url = targetURL

        guard url.hasPrefix(containerURL) else {
            throw FileManagerError.invalidURL(url)
        }

        try contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [],
            options: [ .skipsHiddenFiles ]
        )
        .filter {
            extensions.isEmpty || extensions.contains($0.pathExtension.lowercased())
        }
        .forEach {
            try removeItem(at: $0)
        }
    }

    /// Removes a directory. Succeeds if the directory is contained in the specified directory,
    /// only.
    public func removeDirectory(
        at targetURL: URL,
        in containerURL: URL
    ) throws {
        guard targetURL.isFileURL else {
            throw FileManagerError.invalidScheme(targetURL)
        }
        guard containerURL.isFileURL else {
            throw FileManagerError.invalidScheme(containerURL)
        }

        let url = targetURL

        guard url.hasPrefix(containerURL) else {
            throw FileManagerError.invalidURL(url)
        }

        let path = url.path
        if itemExistsAndIsDirectory(atPath: path) {
            try removeItem(atPath: path)
        }
    }

    /// Removes directories recursively. If the leaf directory is successfully removed, tries to
    /// successively remove every parent directory mentioned in path until the parent directory
    /// is not contained in the specified directory anymore or an error is raised (which is
    /// ignored, because it generally means that a parent directory is not empty).
    public func removeDirectories(
        at targetURL: URL,
        in containerURL: URL
    ) throws {
        guard targetURL.isFileURL else {
            throw FileManagerError.invalidScheme(targetURL)
        }
        guard containerURL.isFileURL else {
            throw FileManagerError.invalidScheme(containerURL)
        }

        var url = targetURL

        guard url.hasPrefix(containerURL) else {
            throw FileManagerError.invalidURL(url)
        }

        repeat {
            let path = url.path
            if itemExistsAndIsDirectory(atPath: path) {
                if try contentsOfDirectory(atPath: path).isEmpty {
                    // directory is empty, delete it
                    try removeItem(atPath: path)
                }
                else {
                    // directory is not empty, stop execution
                    break
                }
                // remove last path component and continue
                url = url.deletingLastPathComponent()
            }
            else {
                // path does not exist or is not directory, stop execution
                break
            }
        } while url.hasPrefix(containerURL)
    }

    public func itemExistsAndIsFile(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        guard fileExists(atPath: path, isDirectory: &isDirectory) else {
            return false
        }
        return isDirectory.boolValue == false
    }

    public func itemExistsAndIsDirectory(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        guard fileExists(atPath: path, isDirectory: &isDirectory) else {
            return false
        }
        return isDirectory.boolValue == true
    }

}

enum FileManagerError: Error {
    case invalidURL(URL)
    case invalidScheme(URL)
}
