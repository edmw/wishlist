import Vapor

import Domain

/// Controller for authenticatable resources:
/// Defines some common functions to be of use in authenticatable resources controllers.
///
/// An resource needing authentication is only accessible to the user who is the owner
/// of the resource.
class AuthenticatableController: Controller {

    /// Returns the id of an authenticated user or nil if there is none.
    /// Before returning two things will be checked:
    /// - a session must exist and a user must be attached to this session
    func authenticatedUserID(on request: Request) throws -> UserID? {
        return try request.authenticated(UserID.self)
    }

    /// Returns the id of an authenticated user or throws if there is none.
    /// Before returning two things will be checked:
    /// - a session must exist and a user must be attached to this session
    /// - a routing parameter matching the user id must exists
    /// Attention: Asumes that the user id is the next routing parameter!
    func requireAuthenticatedUserID(on request: Request) throws -> UserID {
        guard let userid = try authenticatedUserID(on: request) else {
            throw Abort(.unauthorized)
        }
        guard try userid == request.parameters.next(ID.self) else {
            throw Abort(.unauthorized)
        }
        return userid
    }

}
