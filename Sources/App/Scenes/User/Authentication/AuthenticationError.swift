import Vapor

enum AuthenticationError: Error, Debuggable {

    case invalidToken

    case siteLocked

    case internalError

    var identifier: String {
        switch self {
        case .invalidToken: return "AuthInvalidToken"
        case .siteLocked: return "AuthSiteLocked"
        case .internalError: return "AuthInternalError"
        }
    }

    var reason: String {
        switch self {
        case .invalidToken:
            return "Authentication error: Token does not match"
        case .siteLocked:
            return "Authentication could not succeed because site is locked."
        case .internalError:
            return "Authentication could not succeed because an internal error occured (see log)."
        }
    }

}
