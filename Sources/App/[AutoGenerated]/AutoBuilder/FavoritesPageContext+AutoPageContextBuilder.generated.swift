// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Foundation

// MARK: FavoritesPageContext

enum FavoritesPageContextBuilderError: Error {
  case missingRequiredUser
}

class FavoritesPageContextBuilder {

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

    func build() throws -> FavoritesPageContext {
        guard let user = user else {
            throw FavoritesPageContextBuilderError.missingRequiredUser
        }
        return .init(
            for: user,
            with: favorites
        )
    }

}
