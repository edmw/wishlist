import Foundation

// MARK: ImageStoreLocator

/// Typed URL for location images within an `ImageStore`
public struct ImageStoreLocator: CustomStringConvertible, Codable, Hashable {

    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var absoluteString: String {
        return url.absoluteString
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return url.absoluteString
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let url = try URL(from: decoder)
        self.init(url: url)
    }

    public func encode(to encoder: Encoder) throws {
        try url.encode(to: encoder)
    }

}
