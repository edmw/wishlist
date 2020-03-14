import Domain

import Vapor

extension Page {

    static func invitationCreation(
        with user: UserRepresentation,
        editingContext: InvitationEditingContext
    ) throws -> Self {
        return try .init(
            templateName: "User/Invitation",
            context: InvitationPageContext.builder
                .forUser(user)
                .withEditing(editingContext)
                .setAction("form", .post("user", user.id, "invitations"))
                .build()
        )
    }

    static func invitationCreation(with result: RequestInvitationCreation.Result) throws
        -> Self
    {
        let user = result.user
        let editingcontext = InvitationEditingContext()
        return try invitationCreation(with: user, editingContext: editingcontext)
    }

    static func invitationRevocation(with result: RequestInvitationRevocation.Result) throws
        -> Self
    {
        let user = result.user
        let invitation = result.invitation
        return try .init(
            templateName: "User/InvitationRevocation",
            context: InvitationPageContext.builder
                .forUser(user)
                .withInvitation(invitation)
                .setAction("form", .patch("user", user.id, "invitation", invitation.id))
                .build()
        )
    }

}
