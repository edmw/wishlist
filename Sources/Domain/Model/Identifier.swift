import Library

import Foundation

// MARK: AnyIdentifier

public protocol AnyIdentifier {

    var uuid: UUID { get }

}

// MARK: Identifier

public protocol Identifier: AnyIdentifier,
    Loggable,
    Codable,
    Hashable,
    RawRepresentable,
    LosslessStringConvertible
{

    var rawValue: UUID { get }
    var stringValue: String { get }

    init()

    init(uuid: UUID)
    init?(uuid: UUID?)

    init?(string: String)

    init?(rawValue: UUID)

    init?(_ description: String)
    var description: String { get }

    init(from decoder: Decoder) throws
    func encode(to encoder: Encoder) throws
}

extension Identifier {

    public var uuid: UUID {
        return self.rawValue
    }

    public var stringValue: String {
        return rawValue.base62String
    }

    /// Generates a new identifier.
    public init() {
        self.init(uuid: UUID())
    }

    public init?(uuid: UUID?) {
        guard let uuid = uuid else {
            return nil
        }
        self.init(uuid: uuid)
    }

    /// Creates an identifier using the specified string. No checks are made on the given
    /// string. It's completely up to the caller to ensure the validity of the identifier.
    public init?(string: String) {
        guard let uuid = UUID(uuidString: string) else {
            return nil
        }
        self.init(uuid: uuid)
    }

    // MARK: RawRepresentable

    public init?(rawValue: UUID) {
        self.init(uuid: rawValue)
    }

    // MARK: LosslessStringConvertible

    public init?(_ description: String) {
        guard let uuid = UUID(base62String: description) else {
            return nil
        }
        self.init(uuid: uuid)
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return rawValue.base62String
    }

    // MARK: Codable

    /// Decodes the identifier from a single value aka string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(UUID.self)
        self.init(uuid: value)
    }

    /// Encodes the identifier into a single value aka string.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

}

// MARK: -

extension UUID {

    public static func == (lhs: UUID, rhs: AnyIdentifier) -> Bool {
        return lhs == rhs.uuid
    }

    public static func == (lhs: AnyIdentifier, rhs: UUID) -> Bool {
        return lhs.uuid == rhs
    }

}
