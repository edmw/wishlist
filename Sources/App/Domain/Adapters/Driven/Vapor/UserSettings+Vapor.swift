import Domain

import Vapor

extension UserSettings: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        var userSettings = UserSettings()
        userSettings.notifications.pushoverEnabled = true
        return (UserSettings(), userSettings)
    }

}
