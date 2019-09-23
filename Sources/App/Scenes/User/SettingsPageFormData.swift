import Vapor

/// This structures holds all the input given by the user into the settings form.
struct SettingsPageFormData: Content {

    let inputPushover: Bool?
    let inputPushoverKey: String?

    init() {
        self.inputPushover = false
        self.inputPushoverKey = ""
    }

    init(from user: User) {
        self.inputPushover = user.settings.notificationServices.pushoverEnabled
        self.inputPushoverKey = user.settings.notificationServices.pushoverKey
    }

}

extension UserSettings {

    mutating func update(from formdata: SettingsPageFormData) {
        self.notificationServices.pushoverEnabled = formdata.inputPushover ?? false
        self.notificationServices.pushoverKey = formdata.inputPushoverKey ?? ""
    }

}
