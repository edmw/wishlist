import Domain

import Foundation

/// Type which is used in a render context of a page. The reason why `InvitationRepresentation` is
/// not used directly is, the id property has to be converted from `InvitationID` to `ID`.
struct InvitationContext: Encodable {

    let invitation: InvitationRepresentation

    let id: ID?

    enum Keys: String, CodingKey {
        case id
        case code
        case status
        case email
        case sentAt
        case createdAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(id?.string, forKey: .id)
        try container.encode(invitation.code, forKey: .code)
        try container.encode(invitation.status, forKey: .status)
        try container.encode(invitation.email, forKey: .email)
        try container.encode(invitation.sentAt, forKey: .sentAt)
        try container.encode(invitation.createdAt, forKey: .createdAt)
    }

    init(_ invitation: InvitationRepresentation) {
        self.invitation = invitation
        self.id = ID(invitation.id)
    }

    init?(_ invitation: InvitationRepresentation?) {
        guard let invitation = invitation else {
            return nil
        }
        self.init(invitation)
    }

}
