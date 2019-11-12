import Vapor

extension ReservationController {

    // MARK: Save

    struct ReservationSaveResult {
        let reservation: Reservation
        let item: Item
    }

    enum ReservationSaveError: Error {
        case itemReserved
    }

    final class ReservationSaveOutcome: Outcome<ReservationSaveResult, EmptyEncodable> {}

    /// Saves a reservation for the specified list from the request’s data.
    /// Validates the data contained in the request and
    /// creates a new reservation.
    func save(
        from request: Request,
        in list: List,
        for holder: Identification
    ) throws
        -> EventLoopFuture<ReservationSaveOutcome>
    {
        return try self.findItem(in: list, from: request)
            .flatMap { item in
                return try self.reservationRepository
                    .find(item: item.requireID())
                    .flatMap { result in
                        guard result == nil else {
                            // item already reserved (should not happen)
                            return request.future(
                                ReservationSaveOutcome.failure(
                                    with: ReservationSaveError.itemReserved,
                                    context: .init()
                                )
                            )
                        }
                        return try self.save(on: item, in: list, for: holder, on: request)
                            .map { reservation in
                                let value = ReservationSaveResult(
                                    reservation: reservation,
                                    item: item
                                )
                                return .success(with: value, context: .init())
                            }
                    }
            }
    }

    /// Saves a reservation for the specified item and list.
    private func save(
        on item: Item,
        in list: List,
        for holder: Identification,
        on request: Request
    ) throws
        -> EventLoopFuture<Reservation>
    {
        let entity: Reservation
        // create reservation
        entity = try Reservation(item: item, holder: holder)

        return reservationRepository.save(reservation: entity)
    }

}
