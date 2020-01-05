import Foundation

/// Type-erased key-path from a concrete root type to any resulting value type capable of
/// - comparing the values of two properties for the key-path on two given instances
public struct EntityKeyPath<Type: Entity>: Hashable {

    let label: String

    let partialKeyPath: PartialKeyPath<Type>

    private let comparator: (Type, Type) -> Bool

    init<ValueType: Equatable>(_ keypath: KeyPath<Type, ValueType>, label: String) {
        self.label = label
        self.partialKeyPath = keypath

        self.comparator = { $0[keyPath: keypath] == $1[keyPath: keypath] }
    }

    func isEqual(_ lhs: Type, _ rhs: Type) -> Bool {
        return comparator(lhs, rhs)
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
