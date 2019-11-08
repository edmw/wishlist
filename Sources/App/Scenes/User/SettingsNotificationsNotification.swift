import Vapor

final class SettingsNotificationsNotification: UserNotification {

    init(for user: User) {
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
