import Domain

import Vapor

final class TestNotification: UserNotification {

    init(for user: UserRepresentation) {
        super.init(
            for: user,
            titleKey: "settings-notifications-test-title",
            templateName: "User/Notifications/SettingsNotifications",
            templateContext: ["userName": user.fullName]
        )
    }

    func dispatchSend(on request: Request) throws -> EventLoopFuture<Void> {
        return try super.dispatchSend(on: request, before: Date(timeIntervalSinceNow: 10))
    }

}

// MARK: -

extension VaporNotificationSendingProvider {

    func sendTestNotification(
        for user: UserRepresentation,
        using channels: Set<NotificationSendingChannel>
    ) throws -> EventLoopFuture<[NotificationSendingResult]> {
        return try sendUserNotification(
            TestNotification(for: user),
            for: user,
            using: channels,
            dispatch: true
        )
        .unwrap(or: Abort(.internalServerError))
    }

}
