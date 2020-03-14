import Domain

import Vapor

extension Page {

    static func reservationDeletion(with result: RequestReservationDeletion.Result) throws
        -> Self
    {
        let user = result.user
        let list = result.list
        let item = result.item
        let reservation = result.reservation
        return try .init(
            templateName: "User/ReservationDeletion",
            context: ReservationPageContext.builder
                .forIdentification(result.holder)
                .forItem(item)
                .forList(list)
                .withUser(user)
                .withReservation(reservation)
                .setAction(
                    "form",
                    .delete(
                        "user", user.id,
                        "list", list.id,
                        "item", item.id,
                        "reservation", reservation.id
                    )
                )
                .build()
        )
    }

}
