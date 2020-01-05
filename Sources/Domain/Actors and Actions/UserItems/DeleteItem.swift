import Foundation
import NIO

// MARK: DeleteItem

public struct DeleteItem: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
        public static func boundaries(worker: EventLoop, imageStore: ImageStoreProvider) -> Self {
            return Self(worker: worker, imageStore: imageStore)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID
        public static func specification(
            userBy userid: UserID,
            listBy listid: ListID,
            itemBy itemid: ItemID
        ) -> Self {
            return Self(userID: userid, listID: listid, itemID: itemid)
        }
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
            .findWithUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .findWithReservation(by: specification.itemID, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item, reservation in
                        guard reservation == nil else {
                            throw UserItemsActorError.itemIsReserved
                        }
                        self.logging.message(for: item, with: "deleting")
                        // remove images for item
                        try boundaries.imageStore.removeImages(for: item)
                        // delete item
                        return try self.itemRepository
                            .delete(item: item, in: list)
                            .unwrap(or: UserItemsActorError.invalidItem)
                            .logMessage(for: item, "deleted", using: self.logging)
                            .recordEvent(for: item, "deleted for \(user)", using: self.recording)
                            .map { _ in
                                .init(user, list)
                            }
                    }
            }
    }

}
