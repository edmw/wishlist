import Foundation

/// Value type based on a string.
public protocol StringValue: ValueType,
    ExpressibleByStringLiteral,
    LosslessStringConvertible,
    Collection,
    Codable,
    Hashable
{

    init(_ description: String)

    // MARK: String

    var hasLetters: Bool { get }

    var isLetters: Bool { get }

    var hasDigits: Bool { get }

    var isDigits: Bool { get }

}

internal protocol DomainStringValue: StringValue {

    init(string: String)

    var rawValue: String { get }

}

extension DomainStringValue {

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

    /// Decodes the string value from a single value aka string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(string: value)
    }

    /// Encodes the string value into a single value aka string.
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
