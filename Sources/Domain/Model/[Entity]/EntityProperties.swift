// MARK: EntityProperties

public struct EntityProperties<Type: Entity>: Collection {

    public typealias StorageType = [PartialKeyPath<Type>: EntityKeyPath<Type>]

    private var storage = StorageType()

    private init(keyPaths: [EntityKeyPath<Type>]) {
        for keypath in keyPaths {
            storage[keypath.partialKeyPath] = keypath
        }
    }

    func label(for keyPath: PartialKeyPath<Type>) -> String? {
        guard let entityKeyPath = storage[keyPath] else {
            return nil
        }
        return entityKeyPath.label
    }

    static func build(_ keyPaths: EntityKeyPath<Type>...) -> EntityProperties<Type> {
        return .init(keyPaths: keyPaths)
    }

    // MARK: Collection

    public typealias Index = StorageType.Values.Index
    public typealias Element = StorageType.Values.Element

    public var startIndex: Index { return storage.values.startIndex }
    public var endIndex: Index { return storage.values.endIndex }

    public subscript(index: Index) -> Element {
        return storage.values[index]
    }

    public func index(after index: Index) -> Index {
        return storage.values.index(after: index)
    }

}
