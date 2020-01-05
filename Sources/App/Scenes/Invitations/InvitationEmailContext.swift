import Domain

import Vapor

import Foundation

struct InvitationEmailContext: Encodable {

    var invitation: InvitationRepresentation

    var invitationLink: String

    var userID: ID?

    var userFullName: String
    var userFirstName: String

    init(
        for invitation: InvitationRepresentation,
        from user: UserRepresentation,
        on site: Site
    ) throws {
        self.invitation = invitation

        guard let invitationURL = site.url(
            withPath: "/signin/",
            andQueryItems: ["invitation": String(invitation.code)]
        ) else {
            throw Abort(.internalServerError)
        }
        self.invitationLink = invitationURL.absoluteString

        self.userID = ID(user.id)

        self.userFullName = user.fullName
        self.userFirstName = user.firstName
    }

}
