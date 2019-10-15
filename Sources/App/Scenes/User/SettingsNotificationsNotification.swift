import Vapor

final class SettingsNotificationsNotification: Notification {

    init(for user: User) {
        super.init(
            for: user,
            titleKey: "settings-notifications-test-title",
            templateName: "User/SettingsNotificationsNotification",
            templateContext: ["userName": user.fullName]
        )
    }

    func dispatchSend(on request: Request) throws -> EventLoopFuture<Void> {
        return try super.dispatchSend(on: request, before: Date(timeIntervalSinceNow: 10))
    }

}
