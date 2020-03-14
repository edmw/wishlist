// sourcery:inline:WelcomePageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: WelcomePageContext

extension WelcomePageContext {

    static var builder: WelcomePageContextBuilder {
        return WelcomePageContextBuilder()
    }

}

enum WelcomePageContextBuilderError: Error {
  case missingRequiredUser
}

class WelcomePageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var lists: [ListRepresentation]?
    var favorites: [FavoriteRepresentation]?
    var invitations: [InvitationRepresentation]?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withLists(_ lists: [ListRepresentation]?) -> Self {
        self.lists = lists
        return self
    }

    @discardableResult
    func withFavorites(_ favorites: [FavoriteRepresentation]?) -> Self {
        self.favorites = favorites
        return self
    }

    @discardableResult
    func withInvitations(_ invitations: [InvitationRepresentation]?) -> Self {
        self.invitations = invitations
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> WelcomePageContext {
        guard let user = user else {
            throw WelcomePageContextBuilderError.missingRequiredUser
        }
        var context = WelcomePageContext(
            for: user,
            lists: lists,
            favorites: favorites,
            invitations: invitations
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
