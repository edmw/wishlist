import Domain

import Foundation

// MARK: InvitationsPageContext

struct InvitationsPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?

    var userName: String

    var maximumNumberOfInvitations: Int

    var invitations: [InvitationContext]?

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with invitations: [InvitationRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.invitations = invitations?.map { invitation in InvitationContext(invitation) }
    }

}
