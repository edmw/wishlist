import Vapor

import Foundation

/// This type represents a users settings.
struct UserSettings: Content, Validatable, Reflectable, Codable, Equatable {

    var notificationServices: UserSettings.NotificationServices

    struct NotificationServices: Codable, Equatable {

        var pushoverEnabled: Bool = false
        var pushoverKey: String = ""

    }

    init() {
        notificationServices = NotificationServices()
    }

    // MARK: Validatable

    static func validations() throws -> Validations<UserSettings> {
        var validations = Validations(UserSettings.self)
        validations.add("pushoverkey not set while pushover enabled") { settings in
            guard !settings.notificationServices.pushoverEnabled
                || !settings.notificationServices.pushoverKey.isEmpty else {
                throw BasicValidationError("'pushoverkey' missing")
            }
        }
        try validations.add(\.notificationServices.pushoverKey, .empty || .count(3...100))
        return validations
    }

}
