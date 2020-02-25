// MARK: Entity

public protocol Entity: Hashable {
    associatedtype IDType

    var id: IDType? { get }

}

extension Entity where Self: EntityReflectable {

    public static var propertyLabelForId: String {
        return "id"
    }

    // MARK: Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        for keypath in properties {
            if !keypath.isEqual(lhs, rhs){
                return false
            }
        }
        return true
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        for keypath in Self.properties {
            keypath.combine(self, into: &hasher)
        }
    }

}

internal protocol DomainEntity: Entity {
}
