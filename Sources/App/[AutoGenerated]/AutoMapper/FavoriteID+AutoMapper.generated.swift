// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

// MARK: FavoriteID

extension FavoriteID {

    /// Maps an app id to the favoriteid type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}

extension ID {

    /// Maps a favoriteid to the app id type.
    init(_ identifier: FavoriteID) {
        self.init(identifier.rawValue)
    }

    /// Maps an app id to the favoriteid type.
    init?(_ identifier: FavoriteID?) {
        self.init(identifier?.rawValue)
    }

    public static func == (lhs: ID, rhs: FavoriteID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: FavoriteID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
