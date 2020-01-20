import Domain

import Foundation

struct ReservationPageContext: Encodable {

    var identification: ID?

    var userID: ID?

    var reservationID: ID?

    var listID: ID?

    var itemID: ID?

    var itemTitle: String

    var listTitle: String

    fileprivate init(
        for identification: Identification,
        and item: ItemRepresentation,
        in list: ListRepresentation,
        with reservation: ReservationRepresentation? = nil,
        user: UserRepresentation?
    ) {
        self.identification = ID(identification)

        self.userID = ID(user?.id)

        self.reservationID = ID(reservation?.id)

        self.listID = ID(list.id)

        self.itemID = ID(item.id)

        self.itemTitle = item.title

        self.listTitle = list.title
    }

}

// MARK: - Builder

enum ReservationPageContextBuilderError: Error {
    case missingRequiredIdentification
    case missingRequiredItem
    case missingRequiredList
}

class ReservationPageContextBuilder {

    var identification: Identification?
    var user: UserRepresentation?
    var item: ItemRepresentation?
    var list: ListRepresentation?

    var reservation: ReservationRepresentation?

    @discardableResult
    func forIdentification(_ identification: Identification) -> Self {
        self.identification = identification
        return self
    }

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forItem(_ item: ItemRepresentation) -> Self {
        self.item = item
        return self
    }

    @discardableResult
    func forList(_ list: ListRepresentation) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withReservation(_ reservation: ReservationRepresentation?) -> Self {
        self.reservation = reservation
        return self
    }

    func build() throws -> ReservationPageContext {
        guard let item = item else {
            throw ReservationPageContextBuilderError.missingRequiredItem
        }
        guard let list = list else {
            throw ReservationPageContextBuilderError.missingRequiredList
        }
        guard let identification = identification else {
            throw ReservationPageContextBuilderError.missingRequiredIdentification
        }
        return ReservationPageContext(
            for: identification,
            and: item,
            in: list,
            with: reservation,
            user: user
        )
    }

}
