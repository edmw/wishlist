import Foundation

// MARK: ReservationRepresentation

public struct ReservationRepresentation: Encodable, Equatable {

    public let id: ReservationID?

    public let createdAt: Date

    init(
        id: ReservationID?,
        createdAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
    }

    init(_ reservation: Reservation) {
        self.init(
            id: reservation.id,
            createdAt: reservation.createdAt
        )
    }

}
