import Vapor
import Authentication

/// ID parameter for routing:
/// Model types use UUID for model IDs. This class provides a compact representation
/// of UUIDs for use as routing parameters. Technically, the UUID will be encoded as
/// base62 string.
/// For example, "86d5c52d-e7bf-452a-ac0b-064f65f821e8" will become "46QfEaPfUXMcvlP4dPgQJ6".
struct ID: Parameter, CustomStringConvertible, Codable {

    var uuid: UUID

    var string: String? {
        return uuid.base62String
    }

    init(_ uuid: UUID) {
        self.uuid = uuid
    }
    init?(_ uuid: UUID?) {
        guard let uuid = uuid else {
            return nil
        }
        self.uuid = uuid
    }

    /// Attempts to read the parameter from a base62 string into a `UUID`
    public static func resolveParameter(_ parameter: String, on container: Container) throws
        -> ID
    {
        guard let uuid = UUID(base62String: parameter) else {
            throw RoutingError(
                identifier: "ID",
                reason: "The parameter was not convertible to an UUID"
            )
        }
        return ID(uuid)
    }

    // MARK: CustomStringConvertible

    var description: String {
        return uuid.base62String ?? ""
    }

    // MARK: Codable

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base62String = try container.decode(String.self)
        guard let uuid = UUID(base62String: base62String) else {
            throw DecodingError.dataCorruptedError(in: container,
               debugDescription: "Cannot initialize ID from an invalid base62 string"
            )
        }
        self.init(uuid)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(uuid.base62String)
    }

}
