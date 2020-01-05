import Foundation

public enum AuthorizationError: Error {

    case authenticationRequired

    case accessibleForOwnerOnly
    case accessibleForFriendsOnly

    case accessibleForConfidantsOnly

    public var identifier: String {
        switch self {
        case .authenticationRequired: return "AuthZAuthenticationRequired"
        case .accessibleForOwnerOnly: return "AuthZAccessibleForOwnerOnly"
        case .accessibleForFriendsOnly: return "AuthZAccessibleForFriendsOnly"
        case .accessibleForConfidantsOnly: return "AuthZAccessibleForConfidantsOnly"
        }
    }

    public var reason: String {
        switch self {
        case .authenticationRequired:
            return "Authorization error: Authentication required"
        case .accessibleForOwnerOnly:
            return "Authorization error: Accessible for owner only"
        case .accessibleForFriendsOnly:
            return "Authorization error: Accessible for friends only"
        case .accessibleForConfidantsOnly:
            return "Authorization error: Accessible for confidants only"
        }
    }

}
