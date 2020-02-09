import Foundation

// MARK: ReservationRepresentation

public struct ReservationRepresentation: Encodable, Equatable {

    public let id: ReservationID?

    public let createdAt: Date

    init(_ reservation: Reservation) {
        self.id = reservation.id
        self.createdAt = reservation.createdAt
    }

}
