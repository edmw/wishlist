struct SettingsPageFormContext: PageFormContext {

    var data: SettingsPageFormData?

    var missingPushoverKey: Bool
    var invalidPushoverKey: Bool

    init(from data: SettingsPageFormData?) {
        self.data = data

        missingPushoverKey = false
        invalidPushoverKey = false
    }

}
