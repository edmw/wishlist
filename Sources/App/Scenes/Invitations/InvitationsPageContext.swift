import Domain

import Foundation

struct InvitationsPageContext: Encodable {

    var userID: ID?

    var userName: String

    var maximumNumberOfInvitations: Int

    var invitations: [InvitationContext]?

    fileprivate init(
        for user: UserRepresentation,
        with invitations: [InvitationRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.invitations = invitations?.map { invitation in InvitationContext(invitation) }
    }

}

// MARK: - Builder

enum InvitationsPageContextBuilderError: Error {
    case missingRequiredUser
}

class InvitationsPageContextBuilder {

    var user: UserRepresentation?

    var invitations: [InvitationRepresentation]?

    @discardableResult
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withInvitationRepresentations(_ invitations: [InvitationRepresentation]?) -> Self {
        self.invitations = invitations
        return self
    }

    func build() throws -> InvitationsPageContext {
        guard let user = user else {
            throw InvitationsPageContextBuilderError.missingRequiredUser
        }
        return .init(for: user, with: invitations)
    }

}
