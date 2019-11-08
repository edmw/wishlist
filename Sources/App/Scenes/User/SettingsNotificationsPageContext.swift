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

    init(_ result: SendMessageResult, for user: User) {
        self.userID = ID(user.id)

        self.success = result.success

        self.results = result.messaging.map { result -> NotificationResultContext in
            switch result {
            case let .success(messaging):
                return .init(messaging.serviceType, true, 0)
            case let .failure(messaging, error):
                switch error {
                case let .response(status):
                    return .init(messaging.serviceType, false, status)
                default:
                    return .init(messaging.serviceType, false, 500)
                }
            }
        }
    }

}
