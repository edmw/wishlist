import Domain

import Foundation

// MARK: ImageFileLocator

struct ImageFileLocator: CustomStringConvertible {

    let url: URL
    let baseURL: URL

    var absoluteURL: URL {
        return baseURL.appendingPathComponent(url.path, isDirectory: false)
    }
    var absoluteString: String {
        return absoluteURL.absoluteString
    }

    init(absoluteURL givenAbsoluteURL: URL, baseURL givenBaseURL: URL) throws {
        guard givenBaseURL.isLocalFileURL else {
            throw ImageFileLocatorCreationError.invalidBaseURL(givenBaseURL)
        }
        let baseURL = givenBaseURL.standardized

        guard givenAbsoluteURL.isLocalFileURL else {
            throw ImageFileLocatorCreationError.invalidAbsoluteURL(givenAbsoluteURL)
        }
        let absoluteURL = givenAbsoluteURL.standardized

        guard absoluteURL.hasPrefix(baseURL) else {
            throw ImageFileLocatorCreationError.illegalPrefix(absoluteURL, prefix: baseURL)
        }

        let urlString = String(absoluteURL.path.dropFirst(baseURL.path.count + 1))
        guard let url = URL(string: urlString) else {
            throw ImageFileLocatorCreationError.malformedURL(from: urlString)
        }

        self.url = url
        self.baseURL = baseURL
    }

    init(relativeURL givenRelativeURL: URL, baseURL givenBaseURL: URL) throws {
        guard givenBaseURL.isLocalFileURL else {
            throw ImageFileLocatorCreationError.invalidBaseURL(givenBaseURL)
        }
        let baseURL = givenBaseURL.standardized

        guard givenRelativeURL.isLocalFileRelativeURL else {
            throw ImageFileLocatorCreationError.invalidRelativeURL(givenRelativeURL)
        }
        let relativeURL = givenRelativeURL

        self.url = relativeURL
        self.baseURL = baseURL
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return self.absoluteString
    }

}

enum ImageFileLocatorCreationError: Error {
    case invalidBaseURL(URL)
    case invalidAbsoluteURL(URL)
    case invalidRelativeURL(URL)
    case illegalPrefix(URL, prefix: URL)
    case malformedURL(from: String)
}
