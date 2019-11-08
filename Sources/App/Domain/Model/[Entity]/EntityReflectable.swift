protocol EntityReflectable {

    static var properties: [PartialKeyPath<Self>] { get }

    static func propertyName(forKey keyPath: PartialKeyPath<Self>) -> String?

    static var propertyNameForId: String { get }

}
