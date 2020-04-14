import Foundation

// MARK: Identifier

public protocol Identifier: AnyIdentifier,
    Hashable,
    LosslessStringConvertible
{

    var uuid: UUID { get }

    init()

    init(uuid: UUID)
    init?(uuid: UUID?)

    init?(_ description: String)
    var description: String { get }

    init(from decoder: Decoder) throws
    func encode(to encoder: Encoder) throws

}

extension Identifier {

    /// Generates a new identifier.
    public init() {
        self.init(uuid: UUID())
    }

}

// MARK: DomainIdentifier

internal protocol DomainIdentifier: Identifier {

    var rawValue: UUID { get }

    init(rawValue: UUID)

}

extension DomainIdentifier {

    public var uuid: UUID {
        return self.rawValue
    }

    public init(uuid: UUID) {
        self.init(rawValue: uuid)
    }

    public init?(uuid: UUID?) {
        guard let uuid = uuid else {
            return nil
        }
        self.init(rawValue: uuid)
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

// MARK: AnyIdentifier

public protocol AnyIdentifier: Codable {

    var uuid: UUID { get }

}

extension Optional: CustomStringConvertible where Wrapped: AnyIdentifier {

    public var description: String {
        return wrapped.map(String.init(describing:)) ?? "noid"
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
