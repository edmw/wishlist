import Domain

import Vapor

extension Page {

    static func favorites(with result: GetFavorites.Result) throws -> Self {
        return try .init(
            templateName: "User/Favorites",
            context: FavoritesPageContext.builder
                .forUser(result.user)
                .withFavorites(result.favorites)
                .build()
        )
    }

}
