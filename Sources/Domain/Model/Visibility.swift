// swiftlint:disable identifier_name

import Foundation

// MARK: Visibility

public enum Visibility: Int, Codable, LosslessStringConvertible, CustomStringConvertible {

    case ´private´ = 0
    case ´public´ = 1
    case users = 2
    case friends = 3

    public init?(_ description: String) {
        switch description {
        case "private":
            self = .´private´
        case "public":
            self = .´public´
        case "users":
            self = .users
        case "friends":
            self = .friends
        default:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .´private´:
            return "private"
        case .´public´:
            return "public"
        case .users:
            return "users"
        case .friends:
            return "friends"
        }
    }

}
