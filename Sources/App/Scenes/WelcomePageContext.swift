import Foundation

struct WelcomePageContext: Encodable {

    var userID: ID?

    var userName: String
    var userFirstName: String

    var showLists: Bool
    var showInvitations: Bool

    var maximumNumberOfLists: Int
    var maximumNumberOfInvitations: Int

    var lists: [ListContext]?
    var invitations: [InvitationContext]?

    init(
        for user: User,
        lists: [ListContext]? = nil,
        invitations: [InvitationContext]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.name
        self.userFirstName = user.firstName

        self.showLists = true
        self.showInvitations = invitations != nil && user.confidant

        self.maximumNumberOfLists = List.maximumNumberOfListsPerUser
        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.lists = lists
        self.invitations = invitations
    }

}
