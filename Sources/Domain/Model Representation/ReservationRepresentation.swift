import Foundation

// MARK: ReservationRepresentation

public struct ReservationRepresentation: Encodable, Equatable {

    public let id: ReservationID?

    public let createdAt: Date

    internal init(_ reservation: Reservation) {
        self.id = reservation.reservationID

        self.createdAt = reservation.createdAt
    }

}

extension Reservation {

    /// Returns a representation for this model.
    var representation: ReservationRepresentation {
        return .init(self)
    }

}
