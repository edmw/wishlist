import Foundation
import NIO

// MARK: DeleteReservation

public struct DeleteReservation: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let itemID: ItemID
        public let listID: ListID
        public let reservationID: ReservationID
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
                        // delete reservation
                        let id = reservation.reservationID
                        return try reservationRepository
                            .delete(reservation: reservation, for: item)
                            .unwrap(or: UserReservationsActorError.invalidReservation)
                            .logMessage(.deleteReservation(with: id), using: logging)
                            .recordEvent("deleted by \(user)", using: recording)
                            .map { _ in
                                .init(user, item, list)
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func deleteReservation(with id: ReservationID?)
        -> LoggingMessageRoot<Reservation>
    {
        return .init({ reservation in
            LoggingMessage(label: "Delete Reservation", subject: reservation, loggables: [id])
        })
    }

}
