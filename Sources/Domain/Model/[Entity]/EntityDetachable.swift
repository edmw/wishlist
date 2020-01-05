import Foundation
import NIO

// MARK: EntityDetachable

public protocol EntityDetachable: Entity {

    var id: IDType? { get set }

    mutating func detach()

    func detached() -> Self

}

extension EntityDetachable {

    public mutating func detach() {
        self.id = nil
    }

    public func detached() -> Self {
        var detachable = self
        detachable.detach()
        return detachable
    }

}
