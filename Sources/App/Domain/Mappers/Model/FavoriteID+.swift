import Domain

extension ID {

    /// Maps a favorite id to the app id type.
    init(_ identifier: FavoriteID) {
        self.init(identifier.rawValue)
    }

    /// Maps a favorite id to the app id type.
    init?(_ identifier: FavoriteID?) {
        self.init(identifier?.rawValue)
    }

}

extension FavoriteID {

    /// Maps an app id to the favorite id type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}
