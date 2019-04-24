import Vapor

enum AuthenticationError: Error, Debuggable {

    case invalidToken

    case siteLocked
    case notExistingUser
    case notExistingUserNorInvitedUser

    var identifier: String {
        switch self {
        case .invalidToken: return "AuthInvalidToken"
        case .siteLocked: return "AuthSiteLocked"
        case .notExistingUser: return "AuthNotUserExists"
        case .notExistingUserNorInvitedUser: return "AuthNotUserExistsNorUserInvited"
        }
    }

    var reason: String {
        switch self {
        case .invalidToken:
            return "Authentication error: Token does not match"
        case .siteLocked:
            return "Autentication locked for site."
        case .notExistingUser:
            return "Authentication not permitted for non-existing users."
        case .notExistingUserNorInvitedUser:
            return "Authentication not permitted for non-existing or not-invited users."
        }
    }

}
