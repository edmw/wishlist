import Vapor

/// Defines some common functions to be of use in protected resources controllers.
///
/// An resource needing authorization is only accessible if it is public, or accessed
/// by an entitled user.
extension ProtectedController {

    static func requireAuthorization<V: Viewable>(
        on request: Request,
        for viewable: V,
        owner: User,
        user: User?
    ) throws {
        try request.checkAccess(for: viewable, owner: owner, user: user)
    }

}
