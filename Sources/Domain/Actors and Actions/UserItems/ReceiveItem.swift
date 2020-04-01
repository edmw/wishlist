import Foundation
import NIO

// MARK: ReceiveItem

public struct ReceiveItem: Action {

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
        public let reservation: ReservationRepresentation
        internal init(_ user: User, _ list: List, _ item: Item, _ reservation: Reservation) {
            self.user = user.representation
            self.list = list.representation
            self.item = item.representation(with: reservation)
            self.reservation = reservation.representation
        }
    }

    // MARK: -

    internal let actor: () -> ReceiveItemActor

    internal init(actor: @escaping @autoclosure () -> ReceiveItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        on item: Item,
        in list: List,
        with reservation: Reservation,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<(item: Item, reservation: Reservation)>
    {
        let actor = self.actor()
        let reservationRepository = actor.reservationRepository
        guard let itemid = item.id else {
            throw EntityError<Item>.requiredIDMissing
        }
        guard reservation.itemID == itemid else {
            throw EntityError<Item>.invalidRelation
        }
        guard reservation.status == .open else {
            throw ReceiveItemInvalidReservationError(item: item, reservation: reservation)
        }
        reservation.status = .closed
        return reservationRepository
            .save(reservation: reservation)
            .map { reservation in
                return (item, reservation)
            }
    }

}

// MARK: -

protocol ReceiveItemActor {
    var itemRepository: ItemRepository { get }
    var reservationRepository: ReservationRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

protocol ReceiveItemError: ActionError {
    var item: Item { get }
}

struct ReceiveItemInvalidReservationError: ReceiveItemError {
    var item: Item
    var reservation: Reservation
}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: receiveItem

    public func receiveItem(
        _ specification: ReceiveItem.Specification,
        _ boundaries: ReceiveItem.Boundaries
    ) throws -> EventLoopFuture<ReceiveItem.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        return try self.listRepository
            .findAndUser(by: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .findWithReservation(by: itemid, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item, reservation in
                        guard let reservation = reservation, item.receivable(given: reservation)
                            else {
                                throw UserItemsActorError.itemNotReceivable
                            }
                        return try ReceiveItem(actor: self)
                            .execute(on: item, in: list, with: reservation, in: boundaries)
                            .logMessage(
                                .receiveItem(for: user, and: list),
                                for: { $0.0 },
                                using: self.logging
                            )
                            .map { item, reservation in
                                .init(user, list, item, reservation)
                            }
                            .catchMap { error in
                                if let receiveError = error as? ReceiveItemInvalidReservationError {
                                    self.logging.debug("Receive error: \(receiveError)")
                                    throw UserItemsActorError.itemNotReceivable
                                }
                                throw error
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func receiveItem(for user: User, and list: List)
        -> LoggingMessageRoot<Item>
    {
        return .init({ item in
            LoggingMessage(label: "Receive Item", subject: item, loggables: [user, list])
        })
    }

}
