import Domain

import Vapor

final class FavoriteNotificationController: AuthenticatableController,
    FavoriteParameterAcceptor,
    ListParameterAcceptor,
    RouteCollection
{
    let userFavoritesActor: UserFavoritesActor

    init(_ userFavoritesActor: UserFavoritesActor) {
        self.userFavoritesActor = userFavoritesActor
    }

    // MARK: - VIEWS

    //

    // MARK: - CRUD

    // Enables notifications for a favorite with the given listid.
    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        let userFavoritesActor = self.userFavoritesActor
        return try self.findListID(from: request)
            .flatMap { listid in
                return try userFavoritesActor
                    .enableNotifications(
                        .specification(userBy: userid, listBy: listid),
                        .boundaries(worker: request.eventLoop)
                    )
                    .flatMap { result in
                        return self.success(for: result.user, on: request)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // Disables notifications for a favorite with the given listid.
    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        let userFavoritesActor = self.userFavoritesActor
        return try self.findListID(from: request)
            .flatMap { listid in
                return try userFavoritesActor
                    .disableNotifications(
                        .specification(userBy: userid, listBy: listid),
                        .boundaries(worker: request.eventLoop)
                    )
                    .flatMap { result in
                        return self.success(for: result.user, on: request)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for user: UserRepresentation, on request: Request)
        -> EventLoopFuture<Response>
    {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: "/", on: request)
            )
        }
    }

    // MARK: - Routing

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .POST:
                    return try self.create(on: request)
                case .DELETE:
                    return try self.delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // notification handling
        router.post("user", ID.parameter, "favorite", "notifications",
            use: self.dispatch
        )

    }

}
