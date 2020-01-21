import Foundation

// MARK: InvitationRepresentation

public struct InvitationRepresentation: Encodable {

    public let id: InvitationID?

    public let code: InvitationCode
    public let status: String
    public let email: String
    public let sentAt: Date?
    public let createdAt: Date?

    public init(
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

}
