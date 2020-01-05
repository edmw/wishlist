import Foundation
import NIO

// MARK: DeleteReservation

public struct DeleteReservation: Action {

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
        internal init(_ user: User, _ item: Item, _ list: List) {
            self.user = user.representation
            self.item = item.representation
            self.list = list.representation
        }
    }

}

// MARK: - Actor

extension DomainUserReservationsActor {

    // MARK: deleteReservation

    public func deleteReservation(
        _ specification: DeleteReservation.Specification,
        _ boundaries: DeleteReservation.Boundaries
    ) throws -> EventLoopFuture<DeleteReservation.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        let reservationRepository = self.reservationRepository
        let logging = self.logging
        let recording = self.recording
        return try itemRepository
            .findWithListAndUser(by: itemid, in: listid, for: userid)
            .unwrap(or: UserReservationsActorError.invalidItem)
            .flatMap { item, list, user in
                return try reservationRepository
                    .find(for: item)
                    .unwrap(or: UserReservationsActorError.invalidReservation)
                    .flatMap { reservation in
                        return try reservationRepository
                            .delete(reservation: reservation, for: item)
                            .unwrap(or: UserReservationsActorError.invalidReservation)
                            .logMessage("reservation deleted", using: logging)
                            .recordEvent("deleted by \(user)", using: recording)
                            .map { _ in
                                .init(user, item, list)
                            }
                    }
            }
    }

}
