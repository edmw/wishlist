import Domain

extension ID {

    /// Maps a list id to the app id type.
    init(_ identifier: ListID) {
        self.init(identifier.rawValue)
    }

    /// Maps a list id to the app id type.
    init?(_ identifier: ListID?) {
        self.init(identifier?.rawValue)
    }

}

extension ListID {

    /// Maps an app id to the list id type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}
