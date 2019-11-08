import Vapor

final class ReservationDeleteNotification: UserNotification {

    init(for user: User, on item: Item, in list: List) {
        let template: String
        if list.options.contains(.maskReservations) {
            // use this template if the user opted for "Don't spoil my surprises" on the given list
            template = "User/Notifications/ReservationDelete-masked"
        }
        else {
            template = "User/Notifications/ReservationDelete"
        }
        let context = ["itemTitle": item.title, "listTitle": list.title]
        super.init(
            for: user,
            titleKey: "reservations-notifications-delete-title",
            templateName: "\(template)",
            templateContext: context,
            htmlTemplateName: "\(template).html",
            htmlTemplateContext: context
        )
    }

}
