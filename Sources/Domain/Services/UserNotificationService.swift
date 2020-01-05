import Foundation

enum UserNotificationService {

    /// Determines the notification sending channels available for the specified user.
    static func channels(for user: User) -> Set<NotificationSendingChannel> {
        let notifications = user.settings.notifications
        var channels = Set<NotificationSendingChannel>()
        if notifications.emailEnabled {
            channels.insert(.email(user.email))
        }
        if notifications.pushoverEnabled {
            channels.insert(.pushover(notifications.pushoverKey))
        }
        return channels
    }

}
