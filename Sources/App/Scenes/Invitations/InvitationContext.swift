import Vapor

import Foundation

struct InvitationContext: Encodable {

    var id: ID?

    var code: InvitationCode
    var status: String
    var email: String
    var sentAt: Date?
    var createdAt: Date?

    init(for invitation: Invitation) {
        self.id = ID(invitation.id)

        self.code = invitation.code
        self.status = String(describing: invitation.status)
        self.email = invitation.email
        self.sentAt = invitation.sentAt
        self.createdAt = invitation.createdAt
    }

}
