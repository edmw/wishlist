import Foundation
import NIO

// MARK: RemoveReservationFromItem

public struct RemoveReservationFromItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let notificationSending: NotificationSendingProvider
    }

    // MARK: Specification

    public struct Specification: ActionSpecification, WishlistSpecification {
        public let reservationID: ReservationID
        public let listID: ListID
        public let identification: Identification
        public let userID: UserID?
        public static func specification(
            _ reservationid: ReservationID,
            in listid: ListID,
            for identification: Identification,
            userBy userid: UserID?
        ) -> Self {
            return Self(
                reservationID: reservationid,
                listID: listid,
                identification: identification,
                userID: userid
            )
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let item: ItemRepresentation
        public let list: ListRepresentation
        internal init(_ item: Item, _ list: List) {
            self.item = item.representation(with: nil)
            self.list = list.representation
        }
    }

    // MARK: -

    let actor: () -> RemoveReservationFromItemActor

    init(actor: @escaping @autoclosure () -> RemoveReservationFromItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    func execute(
        for reservation: Reservation,
        on item: Item,
        for holder: Identification
    ) throws -> EventLoopFuture<Reservation> {
        guard reservation.holder == holder else {
            throw WishlistActorError.itemHolderMismatch
        }
        let actor = self.actor()
        let reservationRepository = actor.reservationRepository
        return try reservationRepository
            .delete(reservation: reservation, for: item)
            .unwrap(or: WishlistActorError.invalidReservation)
    }

}

// MARK: -

protocol RemoveReservationFromItemActor {
    var reservationRepository: ReservationRepository { get }
}

// MARK: - Actor

extension DomainWishlistActor {

    // MARK: removeReservationFromItem

    public func removeReservationFromItem(
        _ specification: RemoveReservationFromItem.Specification,
        _ boundaries: RemoveReservationFromItem.Boundaries
    ) throws -> EventLoopFuture<RemoveReservationFromItem.Result> {
        let reservationRepository = self.reservationRepository
        let logging = self.logging
        let recording = self.recording
        return authorizeOnWishlist(by: specification)
            .flatMap { authorization, identification in
                let owner = authorization.owner
                let list = authorization.entity
                return try reservationRepository
                    .findWithItem(by: specification.reservationID)
                    .unwrap(or: WishlistActorError.invalidReservation)
                    .flatMap { arguments in let (reservation, item) = arguments
                        // remove reservation
                        let id = reservation.id
                        return try RemoveReservationFromItem(actor: self)
                            .execute(for: reservation, on: item, for: identification)
                            .logMessage(.removeReservationFromItem(with: id), using: logging)
                            .recordEvent("removed for \(identification)", using: recording)
                            .flatMap { reservation in
                                return try boundaries.notificationSending
                                    .notifyReservationDelete(for: owner, on: item, in: list)
                                    .transform(to: reservation)
                            }
                            .map { _ in
                                return .init(item, list)
                            }
                    }
            }
    }

}

extension NotificationSendingProvider {

    fileprivate func notifyReservationDelete(for user: User, on item: Item, in list: List)
        throws -> EventLoopFuture<Void>
    {
        return try self.dispatchSendReservationDeleteNotification(
            for: user.representation,
            on: item.representation,
            in: list.representation,
            using: UserNotificationService.channels(for: user)
        )
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func removeReservationFromItem(with id: ReservationID?)
        -> LoggingMessageRoot<Reservation>
    {
        return .init({ reservation in
            LoggingMessage(
                label: "Remove Reservation from Item",
                subject: reservation,
                loggables: [id]
            )
        })
    }

}
