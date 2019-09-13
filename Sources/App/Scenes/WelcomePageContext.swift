import Foundation

struct WelcomePageContext: Encodable {

    var userID: ID?

    var userName: String
    var userFirstName: String

    var showLists: Bool
    var showFavorites: Bool
    var showInvitations: Bool

    var maximumNumberOfLists: Int
    var maximumNumberOfFavorites: Int
    var maximumNumberOfInvitations: Int

    var lists: [ListContext]?
    var favorites: [ListContext]?
    var invitations: [InvitationContext]?

    init(
        for user: User,
        lists: [ListContext]? = nil,
        favorites: [ListContext]? = nil,
        invitations: [InvitationContext]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.name
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
