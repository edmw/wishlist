import Foundation
import NIO

// MARK: RequestItemEditing

public struct RequestItemEditing: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID?
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        public let item: ItemRepresentation?
        public let reservation: ReservationRepresentation?
        internal init(
            _ user: User,
            _ list: List,
            _ item: Item? = nil,
            _ reservation: Reservation? = nil
        ) {
            self.user = user.representation
            self.list = list.representation
            self.item = item?.representation(with: reservation)
            self.reservation = reservation?.representation
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
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        let worker = boundaries.worker
        return try self.listRepository
            .findAndUser(by: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                if let itemid = itemid {
                    return try self.itemRepository
                        .findWithReservation(by: itemid, in: list)
                        .unwrap(or: UserItemsActorError.invalidItem)
                        .map { item, reservation in
                            .init(user, list, item, reservation)
                        }
                }
                else {
                    return worker.makeSucceededFuture(.init(user, list))
                }
            }
    }

}
