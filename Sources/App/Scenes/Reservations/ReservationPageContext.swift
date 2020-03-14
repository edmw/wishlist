import Domain

import Foundation

// MARK: ReservationPageContext

struct ReservationPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var identification: ID?

    var userID: ID?

    var reservationID: ID?

    var listID: ID?

    var itemID: ID?

    var itemTitle: String

    var listTitle: String

    // sourcery: AutoPageContextBuilderInitializer
    init(
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
