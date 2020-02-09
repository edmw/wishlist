// sourcery:inline:UserID.AutoMapper

// MARK: DO NOT EDIT

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
        self.init(identifier.uuid)
    }

    /// Maps an app id to the userid type.
    init?(_ identifier: UserID?) {
        self.init(identifier?.uuid)
    }

    public static func == (lhs: ID, rhs: UserID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: UserID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
// sourcery:end
