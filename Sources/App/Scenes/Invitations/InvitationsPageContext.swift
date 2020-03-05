import Domain

import Foundation

struct InvitationsPageContext: PageContext, AutoPageContextBuilder {

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
