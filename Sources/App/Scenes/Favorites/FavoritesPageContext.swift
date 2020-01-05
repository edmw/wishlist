import Domain

import Foundation

struct FavoritesPageContext: Encodable {

    var userID: ID?

    var userName: String

    var maximumNumberOfFavorites: Int

    var favorites: [FavoriteContext]?

    fileprivate init(
        for user: UserRepresentation,
        with favorites: [FavoriteRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfFavorites = Favorite.maximumNumberOfFavoritesPerUser

        self.favorites = favorites?.map { favorite in FavoriteContext(favorite) }
    }

}

// MARK: - Builder

enum FavoritesPageContextBuilderError: Error {
    case missingRequiredUser
}

class FavoritesPageContextBuilder {

    var user: UserRepresentation?

    var favorites: [FavoriteRepresentation]?

    @discardableResult
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withFavoriteRepresentations(_ favorites: [FavoriteRepresentation]?) -> Self {
        self.favorites = favorites
        return self
    }

    func build() throws -> FavoritesPageContext {
        guard let user = user else {
            throw FavoritesPageContextBuilderError.missingRequiredUser
        }
        return .init(for: user, with: favorites)
    }

}
