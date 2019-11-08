import Foundation

struct WelcomePageContext: Encodable {

    var userID: ID?

    var userFullName: String
    var userFirstName: String

    var showLists: Bool
    var showFavorites: Bool
    var showInvitations: Bool

    var maximumNumberOfLists: Int
    var maximumNumberOfFavorites: Int
    var maximumNumberOfInvitations: Int

    var lists: [ListContext]?
    var favorites: [FavoriteContext]?
    var invitations: [InvitationContext]?

    fileprivate init(
        for user: User,
        lists: [ListContext]? = nil,
        favorites: [FavoriteContext]? = nil,
        invitations: [InvitationContext]? = nil
    ) {
        self.userID = ID(user.id)

        self.userFullName = user.fullName
        self.userFirstName = user.firstName

        self.showLists = true
        self.showFavorites = favorites != nil
        self.showInvitations = invitations != nil && user.confidant

        self.maximumNumberOfLists = List.maximumNumberOfListsPerUser
        self.maximumNumberOfFavorites = Favorite.maximumNumberOfFavoritesPerUser
        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.lists = lists
        self.favorites = favorites
        self.invitations = invitations
    }

}

// MARK: - Builder

enum WelcomePageContextBuilderError: Error {
    case missingRequiredUser
}

class WelcomePageContextBuilder {

    var user: User?

    var lists: [ListContext]?
    var favorites: [FavoriteContext]?
    var invitations: [InvitationContext]?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withLists(_ lists: [ListContext]) -> Self {
        self.lists = lists
        return self
    }

    @discardableResult
    func withFavorites(_ favorites: [FavoriteContext]) -> Self {
        self.favorites = favorites
        return self
    }

    @discardableResult
    func withInvitations(_ invitations: [InvitationContext]) -> Self {
        self.invitations = invitations
        return self
    }

    func build() throws -> WelcomePageContext {
        guard let user = user else {
            throw WelcomePageContextBuilderError.missingRequiredUser
        }
        return WelcomePageContext(
            for: user,
            lists: lists,
            favorites: favorites,
            invitations: invitations
        )
    }

}
