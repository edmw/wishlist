import Foundation
import NIO

// MARK: DeleteItem

public struct DeleteItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        internal init(_ user: User, _ list: List) {
            self.user = user.representation
            self.list = list.representation
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: deleteItem

    public func deleteItem(
        _ specification: DeleteItem.Specification,
        _ boundaries: DeleteItem.Boundaries
    ) throws -> EventLoopFuture<DeleteItem.Result> {
        return try self.listRepository
            .findAndUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .findWithReservation(by: specification.itemID, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item, reservation in
                        guard item.deletable(given: reservation) else {
                            throw UserItemsActorError.itemNotDeletable
                        }
                        // remove images for item
                        try boundaries.imageStore.removeImages(for: item)
                        // delete item
                        let id = item.id
                        return try self.itemRepository
                            .delete(item: item, in: list)
                            .unwrap(or: UserItemsActorError.invalidItem)
                            .logMessage(.deleteItem(with: id), using: self.logging)
                            .recordEvent(for: item, "deleted for \(user)", using: self.recording)
                            .map { _ in
                                .init(user, list)
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func deleteItem(with id: ItemID?) -> LoggingMessageRoot<Item> {
        return .init({ item in
            LoggingMessage(label: "Delete Item", subject: item, loggables: [id])
        })
    }

}
