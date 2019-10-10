import Vapor

import Foundation

/// This type represents a users settings.
struct UserSettings: Content, Validatable, Reflectable, Codable, Equatable {

    var notifications: UserSettings.Notifications

    struct Notifications: Codable, Equatable {

        var pushoverEnabled: Bool = false
        var pushoverKey: String = ""

    }

    init() {
        notifications = Notifications()
    }

    // MARK: Validatable

    static func validations() throws -> Validations<UserSettings> {
        var validations = Validations(UserSettings.self)
        validations.add("pushoverkey not set while pushover enabled") { settings in
            guard !settings.notifications.pushoverEnabled
                || !settings.notifications.pushoverKey.isEmpty else {
                throw BasicValidationError("'pushoverkey' missing")
            }
        }
        try validations.add(\.notifications.pushoverKey, .empty || .count(3...100))
        return validations
    }

}
