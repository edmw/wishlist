import Vapor

import Foundation

class EntitySorting<T: Entity & EntityReflectable>: ModelQuerySorting {

    static func ascending(by keypath: PartialKeyPath<T>) -> Self {
        return .init(T.propertyName(forKey: keypath), .ascending)
    }

    static func descending(by keypath: PartialKeyPath<T>) -> Self {
        return .init(T.propertyName(forKey: keypath), .descending)
    }

    required init(_ propertyName: String?, _ direction: ModelQuerySortingDirection) {
        super.init(propertyName ?? T.propertyNameForIdKey ?? "id", direction)
    }

    convenience init(_ keypath: PartialKeyPath<T>, _ direction: ModelQuerySortingDirection) {
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
