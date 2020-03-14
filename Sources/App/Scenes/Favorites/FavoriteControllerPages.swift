import Domain

import Vapor

extension Page {

    static func favoriteCreation(with result: RequestFavoriteCreation.Result) throws
        -> Self
    {
        let user = result.user
        let list = result.list
        return try .init(
            templateName: "User/FavoriteCreation",
            context: ListPageContext.builder
                .forUser(user)
                .withList(list)
                .setAction("form", .post("user", user.id, "favorites"))
                .build()
        )
    }

    static func favoriteDeletion(with result: RequestFavoriteDeletion.Result) throws
        -> Self
    {
        let user = result.user
        let list = result.list
        return try .init(
            templateName: "User/FavoriteDeletion",
            context: ListPageContext.builder
                .forUser(user)
                .withList(list)
                .setAction("form", .delete("user", user.id, "favorites", "delete"))
                .build()
        )
    }

}
