// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

// MARK: ItemID

extension ItemID {

    /// Maps an app id to the itemid type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}

extension ID {

    /// Maps a itemid to the app id type.
    init(_ identifier: ItemID) {
        self.init(identifier.rawValue)
    }

    /// Maps an app id to the itemid type.
    init?(_ identifier: ItemID?) {
        self.init(identifier?.rawValue)
    }

    public static func == (lhs: ID, rhs: ItemID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: ItemID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
