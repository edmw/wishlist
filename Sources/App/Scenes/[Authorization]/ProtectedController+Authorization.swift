import Vapor

/// Defines some common functions to be of use in protected resources controllers.
///
/// An resource needing authorization is only accessible if it is public, or accessed
/// by an entitled user.
extension ProtectedController {

    func requireAuthorization<V: Viewable>(
        on request: Request,
        for viewable: V,
        owner: User,
        user: User?
    ) throws -> Authorization<V> {
        try request.checkAccess(for: viewable, owner: owner, user: user)
        return Authorization(resource: viewable, owner: owner, subject: user)
    }

    func requireAuthorization(
        on request: Request,
        for list: List,
        user: User?
    ) throws -> EventLoopFuture<Authorization<List>> {
        // check if the list may be accessed by the given user
        // user may be nil indicating this is a anonymous request
        return list.user.get(on: request).map { owner in
            return try self.requireAuthorization(on: request, for: list, owner: owner, user: user)
        }
    }

}
