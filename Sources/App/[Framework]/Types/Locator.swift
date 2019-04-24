import Vapor

import Foundation

struct Locator: CustomStringConvertible, Codable {

    let url: URL

    var locationString: String {
        return url.absoluteString
    }

    init(_ url: URL) {
        self.url = url
    }

    init?(string: String) {
        guard let url = URL(string: string) else {
            return nil
        }
        self.url = url
    }

    var isLocal: Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        return !components.path.isEmpty
            && components.scheme == nil
            && components.port == nil
            && components.user == nil
            && components.password == nil
            && components.query == nil
            && components.fragment == nil
    }

    // MARK: CustomStringConvertible

    var description: String {
        return locationString
    }

    // MARK: Codable

    /// Decode a Locator from a single String
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let urlString = try container.decode(String.self)
        guard urlString.isEmpty == false else {
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Cannot initialize Locator from an empty string"
            )
        }
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Cannot initialize Locator from an invalid string"
            )
        }
        self.init(url)
    }

    /// Encode a Locator to a single String
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url.absoluteString)
    }

}

// MARK: -

enum LocatorType {
    case any
    case local
}

// MARK: -

class LocatorKeys {
    fileprivate init() {}
}

class LocatorKey: LocatorKeys {

    let string: String

    init(_ string: String) {
        self.string = string

        super.init()
    }

}
