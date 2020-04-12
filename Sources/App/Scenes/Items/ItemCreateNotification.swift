import Domain

import Vapor

final class ItemCreateNotification: UserNotification {

    init(for user: UserRepresentation, on list: ListRepresentation) {
        let context = ["listTitle": list.title]
        super.init(
            for: user,
            titleKey: "items-notifications-create-title",
            templateName: "User/Notifications/ItemCreate",
            templateContext: context,
            htmlTemplateName: "User/Notifications/ItemCreate.html",
            htmlTemplateContext: context
        )
    }

}

// MARK: -

extension VaporNotificationSendingProvider {

    /// Sends a notification when a reservation was added to an item.
    func dispatchSendItemCreateNotification(
        for user: UserRepresentation,
        on list: ListRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<Void> {
        return try dispatchSendUserNotification(
            ItemCreateNotification(for: user, on: list),
            for: user,
            using: channels
        )
    }

}
