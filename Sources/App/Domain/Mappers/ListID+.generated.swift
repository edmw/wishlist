// sourcery:inline:ListID.AutoMapper

// MARK: DO NOT EDIT

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
        self.init(identifier.uuid)
    }

    /// Maps an app id to the listid type.
    init?(_ identifier: ListID?) {
        self.init(identifier?.uuid)
    }

    public static func == (lhs: ID, rhs: ListID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: ListID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
// sourcery:end
