import Vapor

enum AuthorizationError: Error, Debuggable {

    case authenticationRequired

    case accessibleForOwnerOnly
    case accessibleForFriendsOnly

    var identifier: String {
        switch self {
        case .authenticationRequired: return "AuthZAuthenticationRequired"
        case .accessibleForOwnerOnly: return "AuthZAccessibleForOwnerOnly"
        case .accessibleForFriendsOnly: return "AuthZAccessibleForFriendsOnly"
        }
    }

    var reason: String {
        switch self {
        case .authenticationRequired:
            return "Authorization error: Authentication required"
        case .accessibleForOwnerOnly:
            return "Authorization error: Accessible for owner only"
        case .accessibleForFriendsOnly:
            return "Authorization error: Accessible for friends only"
        }
    }

}
