import NIO

// MARK: FavoriteRepository

public protocol FavoriteRepository: EntityRepository {

    var sortingDefault: ListsSorting { get }

    /// Searches a favorite by the specified favorite id. The favorite must belong to the
    /// specified user.
    /// - Parameter id: favorite id to search for
    /// - Parameter user: owner of the favorite
    func find(by id: FavoriteID, for user: User) throws -> EventLoopFuture<Favorite?>
    /// Searches a favorite for the specified list. The favorite must belong to the
    /// specified user.
    /// - Parameter list: list for the search favorite
    /// - Parameter user: owner of the favorite
    func find(favorite list: List, for user: User) throws -> EventLoopFuture<Favorite?>

    /// Returns all favorite lists for the specified user.
    /// - Parameter user: owner of the favorites
    func favorites(for user: User) throws -> EventLoopFuture<[(Favorite, List)]>
    /// Returns all favorites lists for the specified user ordered by the specified
    /// sort order.
    /// - Parameter user: owner of the favorites
    /// - Parameter sort: lists sort order
    func favorites(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[(Favorite, List)]>

    /// Returns all favorites and users for the specified list.
    /// - Parameter list: favoured list
    func favoritesAndUser(for list: List) throws -> EventLoopFuture<[(Favorite, User)]>

    /// Adds the specified list to the favorite lists for the specified user.
    /// - Parameter list: list to add to the favorites
    /// - Parameter user: owner of the favorites
    func addFavorite(_ list: List, for user: User) throws -> EventLoopFuture<Favorite>

    /// Saves the specified favorite.
    /// - Parameter favorite: favorite to be saved
    func save(favorite: Favorite) -> EventLoopFuture<Favorite>

    /// Deletes the specified favorite.
    /// - Parameter favorite: favorite to be deleted
    func delete(favorite: Favorite) throws -> EventLoopFuture<Favorite>

}

extension FavoriteRepository {

    public var sortingDefault: ListsSorting {
        return ListsSorting(\List.title, .ascending)
    }

}
