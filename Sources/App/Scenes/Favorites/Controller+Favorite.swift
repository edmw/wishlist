import Vapor

// MARK: FavoriteParameterAcceptor

protocol FavoriteParameterAcceptor {

    var favoriteRepository: FavoriteRepository { get }

    func requireFavorite(on request: Request, for user: User) throws -> EventLoopFuture<Favorite>

}

extension FavoriteParameterAcceptor where Self: Controller {

    /// Returns the favorite specified by the favorite id given in the request’s route.
    /// Asumes that the favorite id is the next routing parameter!
    /// The favorite must be owned by the specified user.
    func requireFavorite(on request: Request, for user: User) throws -> EventLoopFuture<Favorite> {
        let favoriteID = try request.parameters.next(ID.self)
        return try self.favoriteRepository
            .find(by: favoriteID.uuid, for: user)
            .unwrap(or: Abort(.notFound))
    }

}
