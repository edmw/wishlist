// MARK: EntityProperties

public struct EntityProperties<Type: Entity>: Collection {

    public typealias StorageType = [EntityKeyPath<Type>]
    public typealias MappingType = [PartialKeyPath<Type>: EntityKeyPath<Type>]

    private var storage = StorageType()
    private var mapping = MappingType()

    private init(keyPaths: [EntityKeyPath<Type>]) {
        for keypath in keyPaths {
            storage.append(keypath)
            mapping[keypath.partialKeyPath] = keypath
        }
    }

    func label(for keyPath: PartialKeyPath<Type>) -> String? {
        guard let entityKeyPath = mapping[keyPath] else {
            return nil
        }
        return entityKeyPath.label
    }

    static func build(_ keyPaths: EntityKeyPath<Type>...) -> EntityProperties<Type> {
        return .init(keyPaths: keyPaths)
    }

    // MARK: Collection

    public typealias Index = StorageType.Index
    public typealias Element = StorageType.Element

    public var startIndex: Index { return storage.startIndex }
    public var endIndex: Index { return storage.endIndex }

    public subscript(index: Index) -> Element {
        return storage[index]
    }

    public func index(after index: Index) -> Index {
        return storage.index(after: index)
    }

}
