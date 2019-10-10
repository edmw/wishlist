import Vapor

/// Controller for protected resources:
/// Defines some common functions to be of use in protected resources controllers.
class ProtectedController: Controller {

    /// Returns the list specified by the list id given in the request’s route.
    /// Asumes that the list’s id is the next routing parameter!
    static func requireList(on request: Request) throws -> Future<List> {
        let listID = try request.parameters.next(ID.self)
        return try request.make(ListRepository.self)
            .find(by: listID.uuid)
            .unwrap(or: Abort(.notFound))
    }

    /// Returns the list specified by the list id given in the request’s route.
    /// Asumes that the list’s id is the next routing parameter!
    /// The list must be owned by the specified user.
    static func requireList(on request: Request, for user: User) throws -> Future<List> {
        let listID = try request.parameters.next(ID.self)
        return try request.make(ListRepository.self)
            .find(by: listID.uuid, for: user)
            .unwrap(or: Abort(.notFound))
    }

    /// Returns the item specified by the item id given in the request’s route.
    /// Asumes that the item’s id is the next routing parameter!
    /// The item must part of the specified list.
    static func requireItem(on request: Request, for list: List) throws -> Future<Item> {
        let itemID = try request.parameters.next(ID.self)
        return try request.make(ItemRepository.self)
            .find(by: itemID.uuid, in: list)
            .unwrap(or: Abort(.notFound))
    }

    /// Returns the favorite specified by the favorite id given in the request’s route.
    /// Asumes that the favorite id is the next routing parameter!
    /// The favorite must be owned by the specified user.
    static func requireFavorite(on request: Request, for user: User) throws -> Future<Favorite> {
        let favoriteID = try request.parameters.next(ID.self)
        return try request.make(FavoriteRepository.self)
            .find(by: favoriteID.uuid, for: user)
            .unwrap(or: Abort(.notFound))
    }

}
