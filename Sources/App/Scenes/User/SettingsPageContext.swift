import Foundation

struct SettingsPageContext: Encodable {

    var userID: ID?

    var settings: UserSettings

    var form: SettingsPageFormContext

    init(for user: User, from data: SettingsPageFormData? = nil) {
        self.userID = ID(user.id)

        self.settings = user.settings

        self.form = SettingsPageFormContext(from: data)
    }

}
