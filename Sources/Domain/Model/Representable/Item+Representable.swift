// MARK: Item+Representable

extension Item {

    /// Returns a representation for this model.
    var representation: ItemRepresentation {
        return .init(self)
    }

    /// Returns a representation for this model together with the given reservation.
    func representation(with reservation: Reservation?) -> ItemRepresentation {
        return .init(self, with: reservation)
    }

}
