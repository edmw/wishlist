import Domain

import Vapor

extension Page {

    static func profileAndInvitations(with result: GetProfileAndInvitations.Result) throws
        -> Self
    {
        return try .init(
            templateName: "User/Profile",
            context: ProfilePageContext.builder
                .forUser(result.user)
                .withInvitations(result.invitations)
                .build()
        )
    }

    static func profileEditing(
        with user: UserRepresentation,
        editingContext: ProfileEditingContext
    ) throws -> Self {
        return try .init(
            templateName: "User/ProfileEditing",
            context: ProfilePageContext.builder
                .forUser(user)
                .withEditing(editingContext)
                .setAction("form", .put("user", user.id))
                .build()
        )
    }

    static func profileEditing(with result: RequestProfileEditing.Result) throws
        -> Self
    {
        let user = result.user
        let editingcontext = ProfileEditingContext(from: user)
        return try profileEditing(with: user, editingContext: editingcontext)
    }

}
