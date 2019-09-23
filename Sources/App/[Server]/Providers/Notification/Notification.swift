public enum Notification {

    case email(message: String, subject: String, addresses: [String])
    case pushover(message: String, title: String, users: [String])

    var serviceType: NotificationServiceType {
        switch self {
        case .email:
            return .email
        case .pushover:
            return .pushover
        }
    }

}
