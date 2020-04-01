import Domain

import Vapor

extension Page {

    static func settingsEditing(
        with user: UserRepresentation,
        editingContext: SettingsEditingContext
    ) throws -> Self {
        return try .init(
            templateName: "User/SettingsEditing",
            context: SettingsPageContext.builder
                .forUser(user)
                .withEditing(editingContext)
                .setAction("form", .put("user", user.id, "settings"))
                .build()
        )
    }

    static func settingsEditing(with result: RequestSettingsEditing.Result) throws
        -> Self
    {
        let user = result.user
        let editingcontext = SettingsEditingContext(from: user)
        return try settingsEditing(with: user, editingContext: editingcontext)
    }

}
