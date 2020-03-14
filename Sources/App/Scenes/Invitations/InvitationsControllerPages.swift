import Domain

import Vapor

extension Page {

    static func invitations(with result: GetInvitations.Result) throws -> Self {
        return try .init(
            templateName: "User/Invitations",
            context: InvitationsPageContext.builder
                .forUser(result.user)
                .withInvitations(result.invitations)
                .build()
        )
    }

}
