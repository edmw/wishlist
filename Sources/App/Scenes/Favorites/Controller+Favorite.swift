import Domain

import Vapor

// MARK: FavoriteParameterAcceptor

protocol FavoriteParameterAcceptor {

    func requireFavoriteID(on request: Request) throws -> FavoriteID

}

extension FavoriteParameterAcceptor where Self: Controller {

    /// Returns the favorite id given in the request’s route.
    /// Asumes that the favorite id is the next routing parameter!
    func requireFavoriteID(on request: Request) throws -> FavoriteID {
        return try FavoriteID(request.parameters.next(ID.self))
    }

}
