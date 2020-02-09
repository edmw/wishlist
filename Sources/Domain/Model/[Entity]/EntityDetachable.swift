// MARK: EntityDetachable

public protocol EntityDetachable: Entity {

    mutating func detach()

    func detached() -> Self

}

internal protocol DomainEntityDetachable: EntityDetachable {

    var id: IDType? { get set }

}

extension DomainEntityDetachable {

    public mutating func detach() {
        self.id = nil
    }

    public func detached() -> Self {
        var detachable = self
        detachable.detach()
        return detachable
    }

}
