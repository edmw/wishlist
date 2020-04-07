/// Errors thrown by the User Favorites actor.
public enum UserFavoritesActorError: Error {
    /// An invalid user id was specified. There is no user with the given id.
    case invalidUser
    /// An invalid list id was specified. There is no list with the given id.
    case invalidList
    /// An invalid list id was specified. There is no list with the given id for the specified
    /// user.
    case invalidListForUser
    /// An invalid favorite id was specified. There is no favorite with the given id for the
    /// specified user.
    case invalidFavoriteForUser
    /// Favorite exists already
    case favoriteExisting
    /// Favorite does not exist
    case favoriteNotExisting
}
