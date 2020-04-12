import Foundation

// MARK: UserSettings

/// This type represents a users settings.
public struct UserSettings: Codable, Equatable, Hashable {

    public var notifications: UserSettings.Notifications

    public struct Notifications: Codable, Equatable, Hashable {

        public var enabled: Bool {
            emailEnabled || pushoverEnabled
        }

        public var emailEnabled: Bool = false

        public var pushoverEnabled: Bool = false
        public var pushoverKey = PushoverKey(string: "")

    }

    public init() {
        notifications = Notifications()
    }

}
