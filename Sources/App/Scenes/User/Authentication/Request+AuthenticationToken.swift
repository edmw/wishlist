import Vapor

import Foundation

extension Request {

    /// Returns the authentication token stored in the request’s session.
    func getAuthenticationTokenFromSession() throws -> AuthenticationToken? {
        return try session().getAuthenticationToken()
    }

}
