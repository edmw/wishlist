// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

// MARK: UserID

extension UserID {

    /// Maps an app id to the userid type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}

extension ID {

    /// Maps a userid to the app id type.
    init(_ identifier: UserID) {
        self.init(identifier.rawValue)
    }

    /// Maps an app id to the userid type.
    init?(_ identifier: UserID?) {
        self.init(identifier?.rawValue)
    }

    public static func == (lhs: ID, rhs: UserID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: UserID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
