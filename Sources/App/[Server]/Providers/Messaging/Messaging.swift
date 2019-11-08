public enum Messaging {

    case email(message: String, subject: String, addresses: [EmailAddress])
    case pushover(message: String, title: String, users: [PushoverUser])

    var serviceType: MessagingServiceType {
        switch self {
        case .email:
            return .email
        case .pushover:
            return .pushover
        }
    }

}
