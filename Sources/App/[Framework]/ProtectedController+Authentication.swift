import Vapor

/// Defines some common functions to be of use in protected resources controllers.
///
/// An resource needing authentication is only accessible to the user who is the owner
/// of the resource.
extension ProtectedController {

    /// Returns the authenticated user or nil if there is none.
    /// Before returning a user two things will be checked:
    /// - a session must exist and a user must be attached to this session
    static func getAuthenticatedUser(on request: Request) throws -> User? {
        return try request.authenticated(User.self)
    }

    /// Returns the authenticated user or throws if there is none.
    /// Before returning a user two things will be checked:
    /// - a session must exist and a user must be attached to this session
    /// - a routing parameter matching that user’s id must exists
    /// Attention: Asumes that the user’s id is the next routing parameter!
    static func requireAuthenticatedUser(on request: Request) throws -> User {
        let user = try request.requireAuthenticated(User.self)

        let userid = try request.parameters.next(ID.self).uuid
        guard userid == user.id else { throw Abort(.unauthorized) }

        return user
    }

}
