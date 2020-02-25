import Foundation

// MARK: ImageStoreLocator

public struct ImageStoreLocator: Codable, Hashable {

    public let url: URL

    public init(_ url: URL) {
        self.url = url
    }

    public var absoluteString: String {
        return url.absoluteString
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let url = try URL(from: decoder)
        self.init(url)
    }

    public func encode(to encoder: Encoder) throws {
        try url.encode(to: encoder)
    }

}
