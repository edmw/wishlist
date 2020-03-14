import Domain

import Vapor

extension Page {

    static func wishlist(with result: PresentWishlist.Result) throws -> Self {
        return try .init(
            templateName: "Protected/Wishlist",
            context: WishlistPageContext.builder
                .forList(result.list)
                .forOwner(result.owner)
                .withUser(result.user)
                .isFavorite(result.isFavorite)
                .withItems(result.items)
                .forIdentification(result.identification)
                .build()
        )
    }

    static func reservationCreation(
        with viewContext: WishlistController.RenderReservationViewContext
    ) throws -> Self {
        let item = viewContext.item
        let list = viewContext.list
        return try .init(
            templateName: "Protected/ReservationCreation",
            context: ReservationPageContext.builder
                .forIdentification(viewContext.identification)
                .forItem(item)
                .forList(list)
                .setAction("form", .post("list", list.id, "reservations"))
                .build()
        )
    }

    static func reservationDeletion(
        with viewContext: WishlistController.RenderReservationViewContext
    ) throws -> Self {
        let item = viewContext.item
        let list = viewContext.list
        let reservation = viewContext.reservation
        return try .init(
            templateName: "Protected/ReservationDeletion",
            context: ReservationPageContext.builder
                .forIdentification(viewContext.identification)
                .forItem(item)
                .forList(list)
                .withReservation(reservation)
                .setAction("form", .delete("list", list.id, "reservation", reservation?.id))
                .build()
        )
    }

}
