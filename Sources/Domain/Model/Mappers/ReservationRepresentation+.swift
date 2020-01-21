import DomainModel
import Library

// MARK: ReservationRepresentation

extension ReservationRepresentation {

    internal init(_ reservation: Reservation) {
        self.init(
            id: reservation.reservationID,
            createdAt: reservation.createdAt
        )
    }

}
