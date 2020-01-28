import Domain

import Foundation

struct FavoritesPageContext: Encodable, AutoPageContextBuilder {

    var userID: ID?

    var userName: String

    var maximumNumberOfFavorites: Int

    var favorites: [FavoriteContext]?

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with favorites: [FavoriteRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfFavorites = Favorite.maximumNumberOfFavoritesPerUser

        self.favorites = favorites?.map { favorite in FavoriteContext(favorite) }
    }

}
