import Foundation

struct FavoritesPageContext: Encodable {

    var userID: ID?

    var userName: String

    var maximumNumberOfFavorites: Int

    var favorites: [FavoriteContext]?

    init(for user: User, with favorites: [FavoriteContext]? = nil) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfFavorites = Favorite.maximumNumberOfFavoritesPerUser

        self.favorites = favorites
    }

}
