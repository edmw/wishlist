// sourcery:inline:ReservationID.AutoMapper

// MARK: DO NOT EDIT

import Domain

// MARK: ReservationID

extension ReservationID {

    /// Maps an app id to the reservationid type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}

extension ID {

    /// Maps a reservationid to the app id type.
    init(_ identifier: ReservationID) {
        self.init(identifier.rawValue)
    }

    /// Maps an app id to the reservationid type.
    init?(_ identifier: ReservationID?) {
        self.init(identifier?.rawValue)
    }

    public static func == (lhs: ID, rhs: ReservationID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: ReservationID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
// sourcery:end
