import Vapor
import Fluent

final class FavoriteController: ProtectedController,
    FavoriteParameterAcceptor,
    ListParameterAcceptor,
    RouteCollection
{

    let favoriteRepository: FavoriteRepository
    let itemRepository: ItemRepository
    let listRepository: ListRepository

    init(
        _ favoriteRepository: FavoriteRepository,
        _ itemRepository: ItemRepository,
        _ listRepository: ListRepository
    ) {
        self.favoriteRepository = favoriteRepository
        self.itemRepository = itemRepository
        self.listRepository = listRepository
    }

    // MARK: - VIEWS

    /// Renders a view to confirm the creation of a favorite.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderCreationView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try self.findList(from: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try self.requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        let context = ListPageContext(for: user, with: list)
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
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderDeletionView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try self.findList(from: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try self.requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        let context = ListPageContext(for: user, with: list)
                        return try Controller.renderView(
                            "User/FavoriteDeletion",
                            with: context,
                            on: request
                        )
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // MARK: - CRUD

    // Creates a favorite with the given data.
    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        // get list to create favorite for
        return try self.findList(from: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try self.requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        return try self.favoriteRepository
                            .addFavorite(list, for: user)
                            .emitEvent("created for \(user)", on: request)
                            .logMessage("created for \(user)", on: request)
                            .transform(to: self.success(for: user, on: request))
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // Deletes a favorite with the given data.
    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try self.requireFavorite(on: request, for: user)
            .deleteModel(on: request)
            .emitEvent("deleted for \(user)", on: request)
            .logMessage("deleted for \(user)", on: request)
            .transform(to: success(for: user, on: request))
    }

    // Deletes a favorite with the given listid.
    private func deleteWithListID(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try self.findList(from: request)
            .flatMap { list in
                return try self.favoriteRepository
                    .find(favorite: list, for: user)
                    .unwrap(or: Abort(.notFound))
                    .deleteModel(on: request)
                    .emitEvent("deleted for \(user)", on: request)
                    .logMessage("deleted for \(user)", on: request)
                    .transform(to: self.success(for: user, on: request))
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for user: User, on request: Request) -> EventLoopFuture<Response> {
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
            use: self.deleteWithListID
        )

        // favorite handling

        router.post("user", ID.parameter, "favorite", ID.parameter,
            use: self.dispatch
        )
    }

}
