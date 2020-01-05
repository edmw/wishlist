import Domain

import Foundation

struct WelcomePageContext: Encodable {

    var userID: ID?

    var userFullName: String
    var userFirstName: String

    var showLists: Bool
    var showFavorites: Bool

    var maximumNumberOfLists: Int
    var maximumNumberOfFavorites: Int
    var maximumNumberOfInvitations: Int

    var lists: [ListContext]?
    var favorites: [FavoriteContext]?

    fileprivate init(
        for user: UserRepresentation,
        lists: [ListRepresentation]? = nil,
        favorites: [FavoriteRepresentation]? = nil,
        invitations: [InvitationRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userFullName = user.fullName
        self.userFirstName = user.firstName

        self.showLists = true
        self.showFavorites = favorites != nil

        self.maximumNumberOfLists = List.maximumNumberOfListsPerUser
        self.maximumNumberOfFavorites = Favorite.maximumNumberOfFavoritesPerUser
        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.lists = lists?.map { list in ListContext(list) }
        self.favorites = favorites?.map { favorite in FavoriteContext(favorite) }
    }

}

// MARK: - Builder

enum WelcomePageContextBuilderError: Error {
    case missingRequiredUser
}

class WelcomePageContextBuilder {

    var user: UserRepresentation?

    var lists: [ListRepresentation]?
    var favorites: [FavoriteRepresentation]?

    @discardableResult
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withListRepresentations(_ lists: [ListRepresentation]) -> Self {
        self.lists = lists
        return self
    }

    @discardableResult
    func withFavoriteRepresentations(_ favorites: [FavoriteRepresentation]) -> Self {
        self.favorites = favorites
        return self
    }

    func build() throws -> WelcomePageContext {
        guard let user = user else {
            throw WelcomePageContextBuilderError.missingRequiredUser
        }
        return WelcomePageContext(
            for: user,
            lists: lists,
            favorites: favorites
        )
    }

}
