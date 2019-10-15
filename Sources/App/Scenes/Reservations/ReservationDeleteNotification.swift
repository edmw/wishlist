import Vapor

final class ReservationDeleteNotification: Notification {

    init(for user: User, on item: Item, in list: List) {
        super.init(
            for: user,
            titleKey: "reservations-notifications-delete-title",
            templateName: "User/ReservationDeleteNotification",
            templateContext: ["itemTitle": item.title, "listTitle": list.title],
            htmlTemplateName: "User/ReservationDeleteNotification.html",
            htmlTemplateContext: ["itemTitle": item.title, "listTitle": list.title]
        )
    }

}
