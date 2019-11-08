import Vapor

import Foundation

// MARK: EntitySortingDirection

enum EntitySortingDirection: Int, Codable {
    case ascending = 0
    case descending = 1
}

// MARK: EntitySorting

class EntitySorting<T: Entity & EntityReflectable>: AnyEntitySorting {

    static func ascending(by keypath: PartialKeyPath<T>) -> Self {
        return .init(T.propertyName(forKey: keypath), .ascending)
    }

    static func descending(by keypath: PartialKeyPath<T>) -> Self {
        return .init(T.propertyName(forKey: keypath), .descending)
    }

    required init(_ propertyName: String?, _ direction: EntitySortingDirection) {
        super.init(propertyName ?? T.propertyNameForId, direction)
    }

    convenience init(_ keypath: PartialKeyPath<T>, _ direction: EntitySortingDirection) {
        self.init(T.propertyName(forKey: keypath), direction)
    }

    // MARK: RawRepresentable
    required init?(rawValue: RawValue) {
        super.init(rawValue: rawValue)
    }

    // MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

}

// MARK: - AnyEntitySorting

class AnyEntitySorting: RawRepresentable, Equatable, Codable {

    static func ascending(propertyName: String) -> Self {
        return .init(propertyName, .ascending)
    }

    static func descending(propertyName: String) -> Self {
        return .init(propertyName, .descending)
    }

    let propertyName: String

    let direction: EntitySortingDirection

    required init(_ propertyName: String, _ direction: EntitySortingDirection) {
        self.propertyName = propertyName
        self.direction = direction
    }

    // MARK: RawRepresentable
    typealias RawValue = String

    var rawValue: String {
        let marker: String
        switch direction {
        case .ascending:  marker = "+"
        case .descending: marker = "-"
        }
        return "\(marker)\(propertyName)"
    }

    required init?(rawValue: String) {
        let marker = String(rawValue.prefix(1))
        let propertyName = String(rawValue.dropFirst())
        guard !propertyName.isEmpty else {
            return nil
        }
        if marker == "+" {
            self.propertyName = propertyName
            self.direction = .ascending
        }
        else if marker == "-" {
            self.propertyName = propertyName
            self.direction = .descending
        }
        else {
            return nil
        }
    }

    // MARK: Equatable
    static func == (lhs: AnyEntitySorting, rhs: AnyEntitySorting) -> Bool {
        return lhs.propertyName == rhs.propertyName && lhs.direction == rhs.direction
    }

    // MARK: Codable
    /// Decodes from a single value aka string.
    required init(from decoder: Decoder) throws {
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
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

}
