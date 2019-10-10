import Vapor

final class ReservationCreateNotification: Notification {

    init(for user: User, on item: Item, in list: List) {
        super.init(
            for: user,
            titleKey: "reservations-notifications-create-title",
            templateName: "User/ReservationCreateNotification",
            templateContext: ["itemTitle": item.title, "listTitle": list.title]
        )
    }

}
