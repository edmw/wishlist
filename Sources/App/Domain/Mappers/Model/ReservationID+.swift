import Domain

extension ID {

    /// Maps an reservation id to the app id type.
    init(_ identifier: ReservationID) {
        self.init(identifier.rawValue)
    }

    /// Maps an reservation id to the app id type.
    init?(_ identifier: ReservationID?) {
        self.init(identifier?.rawValue)
    }

}

extension ReservationID {

    /// Maps an app id to the reservation id type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}
