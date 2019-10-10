import Vapor
import Fluent

final class FavoriteController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    /// Renders a view to confirm the creation of a favorite.
    /// This is only accessible for an authenticated user who owns the affected item.
    private static func renderCreationView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try findList(from: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        let context = ListPageContext(for: user, with: list)
                        return try renderView("User/FavoriteCreation", with: context, on: request)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    /// Renders a view to confirm the deletion of a favorite.
    /// This is only accessible for an authenticated user who owns the affected item.
    private static func renderDeletionView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try findList(from: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        let context = ListPageContext(for: user, with: list)
                        return try renderView("User/FavoriteDeletion", with: context, on: request)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // MARK: - CRUD

    // Creates a favorite with the given data.
    private static func create(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        // get list to create favorite for
        return try findList(from: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        return try request.make(FavoriteRepository.self)
                            .addFavorite(list, for: user)
                            .transform(to: success(for: user, on: request))
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // Deletes a favorite with the given data.
    private static func delete(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireFavorite(on: request, for: user)
            .delete(on: request)
            .emitEvent("deleted for \(user)", on: request)
            .transform(to: success(for: user, on: request))
    }

    // Deletes a favorite with the given listid.
    private static func deleteWithListID(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try findList(from: request)
            .flatMap { list in
                return try request.make(FavoriteRepository.self)
                    .find(favorite: list, for: user)
                    .unwrap(or: Abort(.notFound))
                    .delete(on: request)
                    .emitEvent("deleted for \(user)", on: request)
                    .transform(to: success(for: user, on: request))
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for user: User, on request: Request) -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: "/", on: request)
            )
        }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
                switch method {
                case .DELETE:
                    return try delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // favorite creation

        router.get("user", ID.parameter, "favorites", "create",
            use: FavoriteController.renderCreationView
        )
        router.post("user", ID.parameter, "favorites",
            use: FavoriteController.create
        )

        // favorite deletion (by listid)
        router.get("user", ID.parameter, "favorites", "delete",
            use: FavoriteController.renderDeletionView
        )
        router.post("user", ID.parameter, "favorites", "delete",
            use: FavoriteController.deleteWithListID
        )

        // favorite handling

        router.post("user", ID.parameter, "favorite", ID.parameter,
            use: FavoriteController.dispatch
        )
    }

    // MARK: -

    /// Returns the list specified by an list id given in the request’s body or query.
    static func findList(from request: Request) throws -> Future<List> {
        return request.content[ID.self, at: "listID"]
            .flatMap { listID in
                guard let listID = listID ?? request.query[.listID] else {
                    throw Abort(.notFound)
                }
                return try request.make(ListRepository.self)
                    .find(by: listID.uuid)
                    .unwrap(or: Abort(.noContent))
            }
    }

}
