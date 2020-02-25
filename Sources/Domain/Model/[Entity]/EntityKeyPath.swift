// MARK: EntityKeyPath

/// Type-erased key-path from a concrete root type to any resulting value type capable of
/// - comparing the values of two properties for the key-path on two given instances
public struct EntityKeyPath<Type: Entity>: Hashable {

    let label: String

    let partialKeyPath: PartialKeyPath<Type>

    private let comparator: (Type, Type) -> Bool
    private let combinator: (Type, inout Hasher) -> Void

    init<ValueType: Equatable & Hashable>(_ keypath: KeyPath<Type, ValueType>, label: String) {
        self.label = label
        self.partialKeyPath = keypath

        self.comparator = {
            (lhs: Type, rhs: Type) -> Bool in
            return lhs[keyPath: keypath] == rhs[keyPath: keypath]
        }
        self.combinator = {
            (type: Type, hasher: inout Hasher) -> Void in
                hasher.combine(type[keyPath: keypath])
                return
        }
    }

    func isEqual(_ lhs: Type, _ rhs: Type) -> Bool {
        return comparator(lhs, rhs)
    }

    func combine(_ type: Type, into hasher: inout Hasher) {
        combinator(type, &hasher)
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(partialKeyPath)
    }

    // MARK: Equatable

    public static func == (lhs: EntityKeyPath<Type>, rhs: EntityKeyPath<Type>) -> Bool {
        return lhs.partialKeyPath == rhs.partialKeyPath
    }

}
