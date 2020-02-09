import Foundation

// MARK: InvitationRepresentation

public struct InvitationRepresentation: Encodable, Equatable {

    public let id: InvitationID?

    public let code: InvitationCode
    public let status: String
    public let email: String
    public let sentAt: Date?
    public let createdAt: Date?

    init(_ invitation: Invitation) {
        self.id = invitation.id
        self.code = invitation.code
        self.status = String(invitation.status)
        self.email = String(invitation.email)
        self.sentAt = invitation.sentAt
        self.createdAt = invitation.createdAt
    }

}
