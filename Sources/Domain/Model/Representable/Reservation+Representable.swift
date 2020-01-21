import DomainModel

extension Reservation {

    /// Returns a representation for this model.
    var representation: ReservationRepresentation {
        return .init(self)
    }

}
