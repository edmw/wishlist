import Domain

import Vapor

extension Page {

    static func testNotifications(with result: UserNotificationsResult) throws -> Self {
        return .init(
            templateName: "User/SettingsNotificationsSent",
            context: NotificationsPageContext(result, for: result.user)
        )
    }

}
