import DomainModel
import Library

// MARK: InvitationRepresentation

extension InvitationRepresentation {

    internal init(_ invitation: Invitation) {
        self.init(
            id: invitation.invitationID,
            code: invitation.code,
            status: String(invitation.status),
            email: String(invitation.email),
            sentAt: invitation.sentAt,
            createdAt: invitation.createdAt
        )
    }

}
