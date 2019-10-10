public enum Message {

    case email(message: String, subject: String, addresses: [String])
    case pushover(message: String, title: String, users: [String])

    var serviceType: MessagingServiceType {
        switch self {
        case .email:
            return .email
        case .pushover:
            return .pushover
        }
    }

}
