import Domain

import Vapor

// MARK: FavoriteParameterAcceptor

protocol FavoriteParameterAcceptor {

    func requireFavoriteID(on request: Request) throws -> FavoriteID

    func findFavoriteID(from request: Request) throws -> EventLoopFuture<FavoriteID>

}

extension FavoriteParameterAcceptor where Self: Controller {

    /// Returns the favorite id given in the request’s route.
    /// Asumes that the favorite id is the next routing parameter!
    func requireFavoriteID(on request: Request) throws -> FavoriteID {
        return try FavoriteID(request.parameters.next(ID.self))
    }

    /// Searches a favorite id in the request’s content and the request’s query.
    /// - Parameter request: the request
    func findFavoriteID(from request: Request) throws -> EventLoopFuture<FavoriteID> {
        return request.content[ID.self, at: "favoriteID"]
            .map { id in
                guard let id = id ?? request.query[.favoriteID] else {
                    throw Abort(.notFound)
                }
                return FavoriteID(id)
            }
    }
}
