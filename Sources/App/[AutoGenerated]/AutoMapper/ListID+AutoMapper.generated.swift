// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

// MARK: ListID

extension ListID {

    /// Maps an app id to the listid type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}

extension ID {

    /// Maps a listid to the app id type.
    init(_ identifier: ListID) {
        self.init(identifier.rawValue)
    }

    /// Maps an app id to the listid type.
    init?(_ identifier: ListID?) {
        self.init(identifier?.rawValue)
    }

    public static func == (lhs: ID, rhs: ListID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: ListID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
