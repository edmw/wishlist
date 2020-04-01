import Foundation
import NIO

// MARK: AddReservationToItem

public struct AddReservationToItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let notificationSending: NotificationSendingProvider
    }

    // MARK: Specification

    public struct Specification: ActionSpecification, WishlistSpecification {
        public let itemID: ItemID
        public let listID: ListID
        public let identification: Identification
        public let userID: UserID?
        public static func specification(
            _ itemid: ItemID,
            on listid: ListID,
            for identification: Identification,
            userBy userid: UserID?
        ) -> Self {
            return Self(
                itemID: itemid,
                listID: listid,
                identification: identification,
                userID: userid
            )
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let reservation: ReservationRepresentation
        public let item: ItemRepresentation
        public let list: ListRepresentation
        internal init(_ reservation: Reservation, _ item: Item, _ list: List) {
            self.reservation = reservation.representation
            self.item = item.representation(with: reservation)
            self.list = list.representation
        }
    }

    // MARK: -

    internal let actor: () -> AddReservationToItemActor

    internal init(actor: @escaping @autoclosure () -> AddReservationToItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        for item: Item,
        on list: List,
        for holder: Identification
    ) throws -> EventLoopFuture<Reservation> {
        let actor = self.actor()
        let reservationRepository = actor.reservationRepository
        return try reservationRepository
            .find(for: item)
            .flatMap { result in
                guard result == nil else {
                    // item already reserved (should not happen)
                    throw WishlistActorError.itemReservationExist
                }
                // create reservation
                let entity = try Reservation(item: item, holder: holder)
                return reservationRepository
                    .save(reservation: entity)
            }

    }

}

// MARK: -

protocol AddReservationToItemActor {
    var reservationRepository: ReservationRepository { get }
}

// MARK: - Actor

extension DomainWishlistActor {

    // MARK: addReservationToItem

    public func addReservationToItem(
        _ specification: AddReservationToItem.Specification,
        _ boundaries: AddReservationToItem.Boundaries
    ) throws -> EventLoopFuture<AddReservationToItem.Result> {
        let itemRepository = self.itemRepository
        let logging = self.logging
        let recording = self.recording
        return authorizeOnWishlist(by: specification)
            .flatMap { authorization, identification in
                let owner = authorization.owner
                let list = authorization.entity
                return try itemRepository
                    .find(by: specification.itemID, in: list)
                    .unwrap(or: WishlistActorError.invalidItem)
                    .flatMap { item in
                        return try AddReservationToItem(actor: self)
                            .execute(for: item, on: list, for: identification)
                            .logMessage(.addReservationToItem(for: identification), using: logging)
                            .recordEvent("added for \(identification)", using: recording)
                            .flatMap { reservation in
                                return try boundaries.notificationSending
                                    .notifyReservationCreate(for: owner, on: item, in: list)
                                    .transform(to: reservation)
                            }
                            .map { reservation in
                                .init(reservation, item, list)
                            }
                    }
            }
    }

}

extension NotificationSendingProvider {

    fileprivate func notifyReservationCreate(for user: User, on item: Item, in list: List)
        throws -> EventLoopFuture<Void>
    {
        return try self.dispatchSendReservationCreateNotification(
            for: user.representation,
            on: item.representation,
            in: list.representation,
            using: UserNotificationService.channels(for: user)
        )
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func addReservationToItem(for identification: Identification)
        -> LoggingMessageRoot<Reservation>
    {
        return .init({ reservation in
            LoggingMessage(
                label: "Add Reservation to Item",
                subject: reservation,
                loggables: [identification]
            )
        })
    }

}
