import Foundation

// MARK: InvitationRepresentation

public struct InvitationRepresentation: Encodable, Equatable {

    public let id: InvitationID?

    public let code: InvitationCode
    public let status: String
    public let email: String
    public let sentAt: Date?
    public let createdAt: Date?

    init(
        id: InvitationID?,
        code: InvitationCode,
        status: String,
        email: String,
        sentAt: Date?,
        createdAt: Date?
    ) {
        self.id = id
        self.code = code
        self.status = status
        self.email = email
        self.sentAt = sentAt
        self.createdAt = createdAt
    }

    init(_ invitation: Invitation) {
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
