import Foundation

struct NotificationResultContext: Encodable {

    let service: String
    let success: Bool
    let status: UInt

    init(_ notificationServiceType: NotificationServiceType, _ success: Bool, _ status: UInt) {
        self.service = notificationServiceType.stringValue
        self.success = success
        self.status = status
    }
}

struct SettingsNotificationsPageContext: Encodable {

    var userID: ID?

    var results: [NotificationResultContext]

    init(_ notificationResults: [NotificationResult], for user: User) {
        self.userID = ID(user.id)

        self.results = notificationResults.map { result -> NotificationResultContext in
            switch result {
            case let .success(notification):
                return .init(notification.serviceType, true, 0)
            case let .failure(notification, error):
                switch error {
                case let .response(status):
                    return .init(notification.serviceType, false, status)
                default:
                    return .init(notification.serviceType, false, 500)
                }
            }
        }
    }

}
