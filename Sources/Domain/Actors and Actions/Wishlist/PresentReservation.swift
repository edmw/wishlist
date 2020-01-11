import Foundation
import NIO

// MARK: PresentReservation

public struct PresentReservation: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: ActionSpecification, WishlistSpecification {
        public let identification: Identification
        public let itemID: ItemID
        public let listID: ListID
        public let userID: UserID?
        public static func specification(
            _ itemid: ItemID,
            on listid: ListID,
            for identification: Identification,
            userBy userid: UserID?
        ) -> Self {
            return Self(
                identification: identification,
                itemID: itemid,
                listID: listid,
                userID: userid
            )
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let identification: Identification
        public let item: ItemRepresentation
        public let list: ListRepresentation
        public let reservation: ReservationRepresentation?
        internal init(
            identification: Identification,
            _ item: Item,
            _ list: List,
            _ reservation: Reservation?
        ) {
            self.identification = identification
            self.item = item.representation
            self.list = list.representation
            self.reservation = reservation?.representation
        }
    }

}

// MARK: - Actor

extension DomainWishlistActor {

    // MARK: presentReservation

    public func presentReservation(
        _ specification: PresentReservation.Specification,
        _ boundaries: PresentReservation.Boundaries
    ) throws -> EventLoopFuture<PresentReservation.Result> {
        let itemRepository = self.itemRepository
        return authorizeOnWishlist(by: specification)
            .flatMap { authorization, identification in
                let list = authorization.entity
                return try itemRepository
                    .findWithReservation(by: specification.itemID, in: list)
                    .unwrap(or: WishlistActorError.invalidItem)
                    .map { item, reservation in
                        if reservation != nil {
                            guard case let .some(theReservation) = reservation,
                                theReservation.holder == identification
                            else {
                                throw WishlistActorError.invalidReservation
                            }
                        }
                        return .init(identification: identification, item, list, reservation)
                    }
            }
    }

}
