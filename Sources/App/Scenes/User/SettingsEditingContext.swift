import Domain

// MARK: SettingsEditingContext

struct SettingsEditingContext: Codable {

    var data: SettingsEditingData?

    var missingPushoverKey: Bool = false
    var invalidPushoverKey: Bool = false

    static var empty: SettingsEditingContext { return .init(with: nil) }

    init(with data: SettingsEditingData?) {
        self.data = data
    }

    init(from user: UserRepresentation) {
        self.init(with: SettingsEditingData(from: user))
    }

}
