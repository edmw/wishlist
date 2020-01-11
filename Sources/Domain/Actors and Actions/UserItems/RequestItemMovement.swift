import Foundation
import NIO

// MARK: RequestItemMovement

public struct RequestItemMovement: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
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

    // MARK: RequestItemMovement

    public func requestItemMovement(
        _ specification: RequestItemMovement.Specification,
        _ boundaries: RequestItemMovement.Boundaries
    ) throws -> EventLoopFuture<RequestItemMovement.Result> {
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
