import Domain

import Vapor

final class ReservationDeleteNotification: UserNotification {

    init(for user: UserRepresentation, on item: ItemRepresentation, in list: ListRepresentation) {
        let template: String
        if list.maskReservations {
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

// MARK: -

extension VaporNotificationSendingProvider {

    /// Sends a notification when a reservation was removed from an item.
    func dispatchSendReservationDeleteNotification(
        for user: UserRepresentation,
        on item: ItemRepresentation,
        in list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void> {
        return try dispatchSendUserNotification(
            ReservationDeleteNotification(for: user, on: item, in: list),
            for: user,
            using: channels
        )
    }

}
