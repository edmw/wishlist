// MARK: Messaging

public enum Messaging: CustomStringConvertible {

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

    // MARK: CustomStringConvertible

    public var description: String {
        switch self {
        case let .email(_, _, addresses):
            return "email(\(addresses))"
        case let .pushover(_, _, users):
            return "pushover(\(users))"
        }
    }

}
