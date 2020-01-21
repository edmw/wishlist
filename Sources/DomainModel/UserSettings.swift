import Foundation

/// This type represents a users settings.
public struct UserSettings: Codable, Equatable {

    public var notifications: UserSettings.Notifications

    public struct Notifications: Codable, Equatable {

        public var emailEnabled: Bool = false

        public var pushoverEnabled: Bool = false
        public var pushoverKey = PushoverKey(string: "")

    }

    public init() {
        notifications = Notifications()
    }

}
