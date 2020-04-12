import Domain

import Vapor

// MARK: FavoriteController

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
                        try Controller.render(page: .favoriteCreation(with: result), on: request)
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
                        try Controller.render(page: .favoriteDeletion(with: result), on: request)
                            .encode(for: request)
                    }
                    .catchMap(UserFavoritesActorError.self) { _ in
                        // Tries to redirect back to the start page.
                        Controller.redirect(to: "/", on: request)
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
                        self.success(for: result.user, on: request)
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
                        self.success(for: result.user, on: request)
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
        let location = request.query.getLocator(is: .local)?.locationString ?? "/"
        return request.eventLoop.newSucceededFuture(
            result: Controller.redirect(to: location, on: request)
        )
    }

    func boot(router: Router) throws {

        // favorite creation (by listid)

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

    }

}
