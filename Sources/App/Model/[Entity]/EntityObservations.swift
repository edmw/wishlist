import Vapor

import Foundation

// MARK: EntityObservations

class EntityObservationToken {
    private let cancellationClosure: () -> Void

    init(cancellationClosure: @escaping () -> Void) {
        self.cancellationClosure = cancellationClosure
    }

    func cancel() {
        cancellationClosure()
    }
}

typealias EntityCreationObserver<R: EntityRepository, E: Entity> = (R, E) -> Void
typealias EntityDeletionObserver<R: EntityRepository, E: Entity> = (R, E) -> Void

protocol EntityObservations: AnyObject where Self: EntityRepository {
    associatedtype ObservedEntity: Entity

    var observations: (
        created: [UUID: EntityCreationObserver<Self, ObservedEntity>],
        deleted: [UUID: EntityDeletionObserver<Self, ObservedEntity>]
    ) { get set }

    func addCreationObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (T, EntityRepository, Entity) -> Void
    ) -> EntityObservationToken

}

extension EntityRepository where Self: EntityObservations {

    @discardableResult
    func addCreationObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (T, EntityRepository, Entity) -> Void
    ) -> EntityObservationToken {
        let id = UUID()

        observations.created[id] = { [weak self, weak observer] repository, entity in
            guard let observer = observer else {
                self?.observations.created.removeValue(forKey: id)
                return
            }

            closure(observer, repository, entity)
        }

        return EntityObservationToken { [weak self] in
            self?.observations.created.removeValue(forKey: id)
        }
    }

}
