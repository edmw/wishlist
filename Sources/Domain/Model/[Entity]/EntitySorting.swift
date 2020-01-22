// MARK: EntitySortingDirection

public enum EntitySortingDirection: Int, Codable {
    case ascending = 0
    case descending = 1
}

// MARK: EntitySorting

public class EntitySorting<T: Entity & EntityReflectable>: AnyEntitySorting {

    public static func ascending(by keypath: PartialKeyPath<T>) -> Self {
        return .init(T.properties.label(for: keypath), .ascending)
    }

    public static func descending(by keypath: PartialKeyPath<T>) -> Self {
        return .init(T.properties.label(for: keypath), .descending)
    }

    public required init(_ propertyName: String?, _ direction: EntitySortingDirection) {
        super.init(propertyName ?? T.propertyLabelForId, direction)
    }

    public convenience init(_ keypath: PartialKeyPath<T>, _ direction: EntitySortingDirection) {
        self.init(T.properties.label(for: keypath), direction)
    }

    // MARK: RawRepresentable

    required init?(rawValue: RawValue) {
        super.init(rawValue: rawValue)
    }

    // MARK: LosslessStringConvertible

    required init?(_ description: String) {
        super.init(description)
    }

    // MARK: Codable

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

}

// MARK: - AnyEntitySorting

public class AnyEntitySorting: RawRepresentable,
    Equatable,
    Codable,
    LosslessStringConvertible,
    CustomStringConvertible
{

    public static func ascending(propertyName: String) -> Self {
        return .init(propertyName, .ascending)
    }

    public static func descending(propertyName: String) -> Self {
        return .init(propertyName, .descending)
    }

    public let propertyName: String

    public let direction: EntitySortingDirection

    required init(_ propertyName: String, _ direction: EntitySortingDirection) {
        self.propertyName = propertyName
        self.direction = direction
    }

    // MARK: RawRepresentable

    public typealias RawValue = String

    public var rawValue: String {
        let marker: String
        switch direction {
        case .ascending:  marker = "+"
        case .descending: marker = "-"
        }
        return "\(marker)\(propertyName)"
    }

    private static func from(string: String) -> (String, EntitySortingDirection)? {
        let marker = String(string.prefix(1))
        let propertyName = String(string.dropFirst())
        guard !propertyName.isEmpty else {
            return nil
        }
        if marker == "+" {
            return (propertyName, .ascending)
        }
        else if marker == "-" {
            return (propertyName, .descending)
        }
        else {
            return nil
        }
    }

    public required init?(rawValue: String) {
        guard let (propertyName, direction) = AnyEntitySorting.from(string: rawValue) else {
            return nil
        }
        self.propertyName = propertyName
        self.direction = direction
    }

    // MARK: LosslessStringConvertible

    public required init?(_ description: String) {
        guard let (propertyName, direction) = AnyEntitySorting.from(string: description) else {
            return nil
        }
        self.propertyName = propertyName
        self.direction = direction
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return rawValue
    }

    // MARK: Equatable

    public static func == (lhs: AnyEntitySorting, rhs: AnyEntitySorting) -> Bool {
        return lhs.propertyName == rhs.propertyName && lhs.direction == rhs.direction
    }

    // MARK: Codable

    /// Decodes from a single value aka string.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard value.count > 1 else {
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Cannot initialize ModelQuerySorting" +
                    " from an empty string"
            )
        }
        guard let initialized = type(of: self).init(rawValue: value) else {
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Cannot initialize ModelQuerySorting" +
                    " from an invalid string '\(value)'"
            )
        }
        self.propertyName = initialized.propertyName
        self.direction = initialized.direction
    }

    /// Encodes into a single value aka string.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

}
