import Foundation
import NIO

// MARK: RequestItemManagement

public struct RequestItemManagement: Action {

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
        public let reservation: ReservationRepresentation?
        public let lists: [ListRepresentation]
        internal init(
            _ user: User,
            _ list: List,
            _ item: Item,
            _ reservation: Reservation?,
            lists: [ListRepresentation]
        ) {
            self.user = user.representation
            self.list = list.representation
            self.item = item.representation(with: reservation)
            self.reservation = reservation?.representation
            self.lists = lists
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: RequestItemManagement

    public func requestItemManagement(
        _ specification: RequestItemManagement.Specification,
        _ boundaries: RequestItemManagement.Boundaries
    ) throws -> EventLoopFuture<RequestItemManagement.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        let worker = boundaries.worker
        return try self.listRepository
            .findAndUser(by: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .findWithReservation(by: itemid, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item, reservation in
                        return try self.listRepresentationsBuilder
                            .reset()
                            .forUser(user)
                            .build(on: worker)
                            .map { lists in .init(user, list, item, reservation, lists: lists) }
                    }
            }
    }

}
