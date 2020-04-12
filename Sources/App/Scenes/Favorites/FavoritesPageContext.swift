import Domain

import Foundation

// MARK: FavoritesPageContext

struct FavoritesPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?

    var userName: String
    var userNotificationsEnabled: Bool

    var maximumNumberOfFavorites: Int

    var favorites: [FavoriteContext]?

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with favorites: [FavoriteRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName
        self.userNotificationsEnabled = user.settings.notifications.enabled

        self.maximumNumberOfFavorites = Favorite.maximumNumberOfFavoritesPerUser

        self.favorites = favorites?.map { favorite in FavoriteContext(favorite) }
    }

}
