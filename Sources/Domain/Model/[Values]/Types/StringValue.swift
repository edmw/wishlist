import Foundation

/// Value type based on a string.
public protocol StringValue: RawRepresentable,
    ExpressibleByStringLiteral,
    LosslessStringConvertible,
    Collection,
    Codable,
    Hashable
{

    var rawValue: String { get }

    init(string: String)

}

extension StringValue {

    // MARK: RawRepresentable

    public init?(rawValue: String) {
        self.init(string: rawValue)
    }

    // MARK: ExpressibleByStringLiteral

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    // MARK: LosslessStringConvertible

    public init(_ description: String) {
        self.init(string: description)
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return rawValue
    }

    // MARK: Collection

    public var startIndex: String.Index { return rawValue.startIndex }
    public var endIndex: String.Index { return rawValue.endIndex }

    public subscript(index: String.Index) -> String.Element { rawValue[index] }

    public func index(after index: String.Index) -> String.Index { rawValue.index(after: index) }

    // MARK: Codable

    /// Decodes the pushover key from a single value aka string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(string: value)
    }

    /// Encodes the pushover key into a single value aka string.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MARK: String

    public var hasLetters: Bool { rawValue.hasLetters }

    public var isLetters: Bool { rawValue.isLetters }

    public var hasDigits: Bool { rawValue.hasDigits }

    public var isDigits: Bool { rawValue.isDigits }

}