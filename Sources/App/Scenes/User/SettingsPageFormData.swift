import Vapor

/// This structures holds all the input given by the user into the settings form.
struct SettingsPageFormData: Content {
    // swiftlint:disable discouraged_optional_boolean

    let inputEmail: Bool?

    let inputPushover: Bool?
    let inputPushoverKey: String?

    init() {
        self.inputEmail = false
        self.inputPushover = false
        self.inputPushoverKey = ""
    }

    init(from user: User) {
        self.inputEmail = user.settings.notifications.emailEnabled
        self.inputPushover = user.settings.notifications.pushoverEnabled
        self.inputPushoverKey = user.settings.notifications.pushoverKey
    }

}

extension UserSettings {

    mutating func update(from formdata: SettingsPageFormData) {
        self.notifications.emailEnabled = formdata.inputEmail ?? false
        self.notifications.pushoverEnabled = formdata.inputPushover ?? false
        self.notifications.pushoverKey = formdata.inputPushoverKey ?? ""
    }

}