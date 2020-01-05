import Foundation

// MARK: InvitationRepresentation

public struct InvitationRepresentation: Encodable, Equatable {

    public let id: InvitationID?

    public let code: InvitationCode
    public let status: String
    public let email: String
    public let sentAt: Date?
    public let createdAt: Date?

    internal init(_ invitation: Invitation) {
        self.id = invitation.invitationID

        self.code = invitation.code
        self.status = String(invitation.status)
        self.email = String(invitation.email)
        self.sentAt = invitation.sentAt
        self.createdAt = invitation.createdAt
    }

}

extension Invitation {

    /// Returns a representation for this model.
    var representation: InvitationRepresentation {
        return .init(self)
    }

}
