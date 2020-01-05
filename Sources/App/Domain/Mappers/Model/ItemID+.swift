import Domain

extension ID {

    /// Maps an item id to the app id type.
    init(_ identifier: ItemID) {
        self.init(identifier.rawValue)
    }

    /// Maps an item id to the app id type.
    init?(_ identifier: ItemID?) {
        self.init(identifier?.rawValue)
    }

}

extension ItemID {

    /// Maps an app id to the item id type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}
