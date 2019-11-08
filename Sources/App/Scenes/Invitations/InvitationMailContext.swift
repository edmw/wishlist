import Vapor

import Foundation

struct InvitationMailContext: Encodable {

    var invitation: InvitationContext

    var invitationLink: String

    var userID: ID?

    var userFullName: String
    var userFirstName: String

    init(for invitation: Invitation, from user: User, on site: Site) throws {
        self.invitation = InvitationContext(for: invitation)

        guard let invitationURL = site.url(
            withPath: "/signin/",
            andQueryItems: ["invitation": String(describing: invitation.code)]
        ) else {
            throw Abort(.internalServerError)
        }
        self.invitationLink = invitationURL.absoluteString

        self.userID = ID(user.id)

        self.userFullName = user.fullName
        self.userFirstName = user.firstName
    }

}
