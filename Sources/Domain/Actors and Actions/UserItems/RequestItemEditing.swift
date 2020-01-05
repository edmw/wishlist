import Foundation
import NIO

// MARK: RequestItemEditing

public struct RequestItemEditing: Action {

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
        public let itemID: ItemID?
        public static func specification(
            userBy userid: UserID,
            listBy listid: ListID,
            itemBy itemid: ItemID?
        ) -> Self {
            return Self(userID: userid, listID: listid, itemID: itemid)
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        public let item: ItemRepresentation?
        internal init(_ user: User, _ list: List, _ item: Item? = nil) {
            self.user = user.representation
            self.list = list.representation
            self.item = item?.representation
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: requestItemEditing

    public func requestItemEditing(
        _ specification: RequestItemEditing.Specification,
        _ boundaries: RequestItemEditing.Boundaries
    ) throws -> EventLoopFuture<RequestItemEditing.Result> {
        let worker = boundaries.worker
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserItemsActorError.invalidUser)
            .flatMap { user in
                return try self.listRepository
                    .find(by: specification.listID, for: user)
                    .unwrap(or: UserItemsActorError.invalidList)
                    .flatMap { list in
                        if let itemID = specification.itemID {
                            return try self.itemRepository
                                .findWithReservation(by: itemID, in: list)
                                .unwrap(or: UserItemsActorError.invalidItem)
                                .map { item, _ in
                                    .init(user, list, item)
                                }
                        }
                        else {
                            return worker.makeSucceededFuture(.init(user, list))
                        }
                    }
            }
    }

}
