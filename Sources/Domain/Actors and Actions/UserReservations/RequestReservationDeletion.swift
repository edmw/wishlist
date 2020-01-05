import Foundation
import NIO

// MARK: RequestReservationDeletion

public struct RequestReservationDeletion: Action {

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
        public let itemID: ItemID
        public let listID: ListID
        public let reservationID: ReservationID
        public static func specification(
            userBy userid: UserID,
            itemBy itemid: ItemID,
            listBy listid: ListID,
            reservationid: ReservationID
        ) -> Self {
            return Self(
                userID: userid,
                itemID: itemid,
                listID: listid,
                reservationID: reservationid
            )
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let item: ItemRepresentation
        public let list: ListRepresentation
        public let reservation: ReservationRepresentation
        public let holder: Identification
        internal init(
            _ user: User,
            _ item: Item,
            _ list: List,
            _ reservation: Reservation,
            holder: Identification
        ) {
            self.user = user.representation
            self.item = item.representation
            self.list = list.representation
            self.reservation = reservation.representation
            self.holder = holder
        }
    }

}

// MARK: - Actor

extension DomainUserReservationsActor {

    // MARK: requestReservationDeletion

    public func requestReservationDeletion(
        _ specification: RequestReservationDeletion.Specification,
        _ boundaries: RequestReservationDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestReservationDeletion.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        let reservationRepository = self.reservationRepository
        return try itemRepository
            .findWithListAndUser(by: itemid, in: listid, for: userid)
            .unwrap(or: UserReservationsActorError.invalidItem)
            .flatMap { item, list, user in
                return try reservationRepository
                    .find(for: item)
                    .unwrap(or: UserReservationsActorError.invalidReservation)
                    .map { reservation in
                        return .init(user, item, list, reservation, holder: reservation.holder)
                    }
            }
    }

}
