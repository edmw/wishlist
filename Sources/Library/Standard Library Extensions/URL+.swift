///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - URL+
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

// MARK: URL

extension URL {

    public func hasPrefix(_ url: URL) -> Bool {
        return self.scheme == url.scheme
            && self.host == url.host
            && self.absoluteString.hasPrefix(url.absoluteString)
    }

    // MARK: isFileURL

    public var isLocalFileURL: Bool {
        return self.isFileURL && self.host == nil
    }

    public var isLocalFileAbsoluteURL: Bool {
        if let scheme = self.scheme {
            guard scheme == "file" else {
                return false
            }
            return self.host == nil && self.baseURL == nil
        }
        else {
            return self.host == nil && self.relativePath.hasPrefix("/")
        }
    }

    public var isLocalFileRelativeURL: Bool {
        if let scheme = self.scheme {
            guard scheme == "file" else {
                return false
            }
            return self.host == nil && self.baseURL != nil
        }
        else {
            return self.host == nil && !self.relativePath.hasPrefix("/")
        }
    }

    /// Resource type of this URL. Returns `unknown` if unattainable.
    public var resourceType: URLFileResourceType {
        return ((try? resourceValues(forKeys:
            [.fileResourceTypeKey]))?.fileResourceType) ?? .unknown
    }

    /// `true` if, and only if, this resource is a regular file, or symbolic link to a regular file.
    public var isRegularFile: Bool {
        return ((try? resourceValues(forKeys:
            [.isRegularFileKey]))?.isRegularFile) ?? false
    }

    /// `true` if, and only if, this resource is a directory, or symbolic link to a directory.
    public var isDirectory: Bool {
        return ((try? resourceValues(forKeys:
            [.isDirectoryKey]))?.isDirectory) ?? false
    }

    /// Date this resource was created or `distantFuture` if unobtainable.
    public var creationDate: Date {
        return ((try? resourceValues(forKeys:
            [.creationDateKey]))?.creationDate) ?? .distantFuture
    }

    /// Date this resource was accessed or `distantFuture` if unobtainable.
    public var accessDate: Date {
        return ((try? resourceValues(forKeys:
            [.contentAccessDateKey]))?.contentAccessDate) ?? .distantFuture
    }

    /// Date this resource was modified choosing the most recent between `attributeModificationDate`
    /// and `contentModificationDate` or `distantFuture` if unobtainable.
    public var modificationDate: Date {
        return attributeModificationDate > contentModificationDate ?
            attributeModificationDate : contentModificationDate
    }

    /// Date the the attributes of this resource were modified.
    public var attributeModificationDate: Date {
        return ((try? resourceValues(forKeys:
            [.attributeModificationDateKey]))?.attributeModificationDate) ?? .distantFuture
    }

    /// Date the the contents of this resource were modified.
    public var contentModificationDate: Date {
        return ((try? resourceValues(forKeys:
            [.contentModificationDateKey]))?.contentModificationDate) ?? .distantFuture
    }

}
