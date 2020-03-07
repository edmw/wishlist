import Domain

import Vapor
import Fluent

final class FavoriteController: AuthenticatableController,
    FavoriteParameterAcceptor,
    ListParameterAcceptor,
    RouteCollection
{
    let userFavoritesActor: UserFavoritesActor

    init(_ userFavoritesActor: UserFavoritesActor) {
        self.userFavoritesActor = userFavoritesActor
    }

    // MARK: - VIEWS

    /// Renders a view to confirm the creation of a favorite.
    private func renderCreationView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        let userFavoritesActor = self.userFavoritesActor
        return try self.findListID(from: request)
            .flatMap { listid in
                return try userFavoritesActor
                    .requestFavoriteCreation(
                        .specification(userBy: userid, listBy: listid),
                        .boundaries(worker: request.eventLoop)
                    )
                    .flatMap { result in
                        let context = try ListPageContext.builder
                            .forUser(result.user)
                            .withList(result.list)
                            .build()
                        return try Controller.renderView(
                            "User/FavoriteCreation",
                            with: context,
                            on: request
                        )
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    /// Renders a view to confirm the deletion of a favorite.
    private func renderDeletionView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        let userFavoritesActor = self.userFavoritesActor
        return try self.findListID(from: request)
            .flatMap { listid in
                return try userFavoritesActor
                    .requestFavoriteDeletion(
                        .specification(userBy: userid, listBy: listid),
                        .boundaries(worker: request.eventLoop)
                    )
                    .flatMap { result in
                        let context = try ListPageContext.builder
                            .forUser(result.user)
                            .withList(result.list)
                            .build()
                        return try Controller.renderView(
                            "User/FavoriteDeletion",
                            with: context,
                            on: request
                        )
                        .encode(for: request)
                    }
                    .catchMap(UserFavoritesActorError.self) { _ in
                        // Tries to redirect back to the start page.
                        return Controller.redirect(to: "/", on: request)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // MARK: - CRUD

    // Creates a favorite with the given listid.
    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        let userFavoritesActor = self.userFavoritesActor
        return try self.findListID(from: request)
            .flatMap { listid in
                return try userFavoritesActor
                    .createFavorite(
                        .specification(userBy: userid, listBy: listid),
                        .boundaries(worker: request.eventLoop)
                    )
                    .flatMap { result in
                        return self.success(for: result.user, on: request)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // Deletes a favorite with the given listid.
    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        let userFavoritesActor = self.userFavoritesActor
        return try self.findListID(from: request)
            .flatMap { listid in
                return try userFavoritesActor
                    .deleteFavorite(
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
                case .DELETE:
                    return try self.delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // favorite creation

        router.get("user", ID.parameter, "favorites", "create",
            use: self.renderCreationView
        )
        router.post("user", ID.parameter, "favorites",
            use: self.create
        )

        // favorite deletion (by listid)
        router.get("user", ID.parameter, "favorites", "delete",
            use: self.renderDeletionView
        )
        router.post("user", ID.parameter, "favorites", "delete",
            use: self.delete
        )

        // favorite handling

        router.post("user", ID.parameter, "favorite", ID.parameter,
            use: self.dispatch
        )
    }

}
