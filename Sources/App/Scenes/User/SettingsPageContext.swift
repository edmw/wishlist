import Domain

import Foundation

struct SettingsPageContext: PageContext, AutoPageContextBuilder {

    var userID: ID?

    var settings: UserSettings

    var form: SettingsPageFormContext

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        from formData: SettingsPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.settings = user.settings

        self.form = SettingsPageFormContext(from: formData)
    }

}
