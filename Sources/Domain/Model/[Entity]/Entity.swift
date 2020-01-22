// MARK: Entity

public protocol Entity: Equatable {
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

}
