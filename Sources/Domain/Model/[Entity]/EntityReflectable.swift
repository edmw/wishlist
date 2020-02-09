// MARK: EntityReflectable

public protocol EntityReflectable: Entity {

    static var properties: EntityProperties<Self> { get }

    static var propertyLabelForId: String { get }

}

internal protocol DomainEntityReflectable: EntityReflectable {
}
