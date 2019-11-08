import Foundation

struct ReservationPageContext: Encodable {

    var identification: ID?

    var userID: ID?

    var reservationID: ID?

    var itemID: ID?

    var listID: ID?

    var itemTitle: String

    var listTitle: String

    fileprivate init(
        for identification: Identification,
        and item: Item,
        in list: List,
        with reservation: Reservation? = nil
    ) {
        self.identification = ID(identification)

        self.reservationID = ID(reservation?.id)

        self.itemID = ID(item.id)

        self.listID = ID(list.id)

        self.itemTitle = item.title

        self.listTitle = list.title
    }

    fileprivate init(
        for user: User,
        and item: Item,
        in list: List,
        with reservation: Reservation? = nil
    ) {
        self.userID = ID(user.id)

        self.reservationID = ID(reservation?.id)

        self.itemID = ID(item.id)

        self.listID = ID(list.id)

        self.itemTitle = item.title

        self.listTitle = list.title
    }

}

// MARK: - Builder

enum ReservationPageContextBuilderError: Error {
    case missingRequiredIdentificationOrUser
    case eitherRequiredIdentificationOrUser
    case missingRequiredItem
    case missingRequiredList
}

class ReservationPageContextBuilder {

    var identification: Identification?
    var user: User?
    var item: Item?
    var list: List?

    var reservation: Reservation?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forIdentification(_ identification: Identification) -> Self {
        self.identification = identification
        return self
    }

    @discardableResult
    func forItem(_ item: Item) -> Self {
        self.item = item
        return self
    }

    @discardableResult
    func forList(_ list: List) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withReservation(_ reservation: Reservation) -> Self {
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
        // builder needs at least either identification ...
        if let identification = identification {
            guard user == nil else {
                throw ReservationPageContextBuilderError.eitherRequiredIdentificationOrUser
            }
            return ReservationPageContext(
                for: identification,
                and: item,
                in: list,
                with: reservation
            )
        }
        // ... or user ...
        else if let user = user {
            guard identification == nil else {
                throw ReservationPageContextBuilderError.eitherRequiredIdentificationOrUser
            }
            return ReservationPageContext(
                for: user,
                and: item,
                in: list,
                with: reservation
            )
        }
        else {
            // ... and not both
            throw ReservationPageContextBuilderError.missingRequiredIdentificationOrUser
        }
    }

}
