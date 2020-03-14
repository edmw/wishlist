// sourcery:inline:FavoritesPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: FavoritesPageContext

extension FavoritesPageContext {

    static var builder: FavoritesPageContextBuilder {
        return FavoritesPageContextBuilder()
    }

}

enum FavoritesPageContextBuilderError: Error {
  case missingRequiredUser
}

class FavoritesPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var favorites: [FavoriteRepresentation]?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withFavorites(_ favorites: [FavoriteRepresentation]?) -> Self {
        self.favorites = favorites
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> FavoritesPageContext {
        guard let user = user else {
            throw FavoritesPageContextBuilderError.missingRequiredUser
        }
        var context = FavoritesPageContext(
            for: user,
            with: favorites
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
