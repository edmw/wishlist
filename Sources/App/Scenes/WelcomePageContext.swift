import Domain

import Foundation

// MARK: WelcomePageContext

struct WelcomePageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

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

    // sourcery: AutoPageContextBuilderInitializer
    init(
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
