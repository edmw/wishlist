import Foundation

struct NotificationResultContext: Encodable {

    let service: String
    let success: Bool
    let status: UInt

    init(_ serviceType: MessagingServiceType, _ success: Bool, _ status: UInt) {
        self.service = serviceType.stringValue
        self.success = success
        self.status = status
    }

}

struct SettingsNotificationsPageContext: Encodable {

    var userID: ID?

    var success: Bool

    var results: [NotificationResultContext]

    init(for user: User) {
        self.userID = ID(user.id)

        self.success = false

        self.results = []
    }

    init(_ result: SendNotificationResult, for user: User) {
        self.userID = ID(user.id)

        self.success = result.success

        self.results = result.messaging.map { result -> NotificationResultContext in
            switch result {
            case let .success(message):
                return .init(message.serviceType, true, 0)
            case let .failure(message, error):
                switch error {
                case let .response(status):
                    return .init(message.serviceType, false, status)
                default:
                    return .init(message.serviceType, false, 500)
                }
            }
        }
    }

}
