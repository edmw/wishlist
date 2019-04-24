import Foundation

struct ReservationPageContext: Encodable {

    var identification: ID?

    var userID: ID?

    var reservationID: ID?

    var itemID: ID?

    var listID: ID?

    var itemName: String

    var listName: String

    init(
        for identification: Identification,
        and item: Item,
        in list: List,
        with reservation: Reservation? = nil
    ) {
        self.identification = ID(identification)

        self.reservationID = ID(reservation?.id)

        self.itemID = ID(item.id)

        self.listID = ID(list.id)

        self.itemName = item.name

        self.listName = list.name
    }

    init(
        for user: User,
        and item: Item,
        in list: List,
        with reservation: Reservation? = nil
    ) {
        self.userID = ID(user.id)

        self.reservationID = ID(reservation?.id)

        self.itemID = ID(item.id)

        self.listID = ID(list.id)

        self.itemName = item.name

        self.listName = list.name
    }

}
