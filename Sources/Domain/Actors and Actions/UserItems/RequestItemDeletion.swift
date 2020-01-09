import Foundation
import NIO

// MARK: RequestItemDeletion

public struct RequestItemDeletion: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public static func boundaries(worker: EventLoop) -> Self {
            return Self(worker: worker)
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
        public let item: ItemRepresentation
        internal init(_ user: User, _ list: List, _ item: Item) {
            self.user = user.representation
            self.list = list.representation
            self.item = item.representation
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: requestItemDeletion

    public func requestItemDeletion(
        _ specification: RequestItemDeletion.Specification,
        _ boundaries: RequestItemDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestItemDeletion.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        return try self.itemRepository
            .findWithListAndUser(by: itemid, in: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidItem)
            .map { item, list, user in
                .init(user, list, item)
            }
    }

}
