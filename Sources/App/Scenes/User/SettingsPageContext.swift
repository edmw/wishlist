import Domain

import Foundation

// MARK: SettingsPageContext

struct SettingsPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?

    var settings: UserSettings

    var form: SettingsEditingContext

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        from editingContext: SettingsEditingContext? = nil
    ) {
        self.userID = ID(user.id)

        self.settings = user.settings

        self.form = editingContext ?? .empty
    }

}
