import Foundation

// MARK: NotificationSendingChannel

public enum NotificationSendingChannel: Hashable {

    case email(EmailSpecification)
    case pushover(PushoverKey)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .email:
            hasher.combine("email")
        case .pushover:
            hasher.combine("pushover")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.email, .email):
            return true
        case (.pushover, .pushover):
            return true
        case (.email, _), (.pushover, _):
            return false
        }
    }

}
