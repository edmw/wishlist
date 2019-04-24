// swiftlint:disable identifier_name

import Foundation

enum Visibility: Int, Codable, CustomStringConvertible {

    case ´private´ = 0
    case ´public´ = 1
    case users = 2
    case friends = 3

    var description: String {
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
