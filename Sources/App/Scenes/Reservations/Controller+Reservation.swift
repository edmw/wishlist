import Vapor

// MARK: ReservationParameterAcceptor

protocol ReservationParameterAcceptor {

    var reservationRepository: ReservationRepository { get }
    var itemRepository: ItemRepository { get }

    func requireReservation(on request: Request) throws -> EventLoopFuture<Reservation>

    func requireReservation(on request: Request, for item: Item) throws
        -> EventLoopFuture<Reservation>

}

extension ReservationParameterAcceptor where Self: Controller {

    /// Returns the reservation specified by the reservation id given in the request’s route.
    /// Asumes that the reservation’s id is the next routing parameter!
    func requireReservation(on request: Request) throws -> EventLoopFuture<Reservation> {
        let reservationID = try request.parameters.next(ID.self)
        return self.reservationRepository
            .find(by: reservationID.uuid)
            .unwrap(or: Abort(.noContent))
    }

    /// Returns the reservation specified by the reservation id given in the request’s route.
    /// Asumes that the reservation’s id is the next routing parameter!
    func requireReservation(
        on request: Request,
        for item: Item
    ) throws -> EventLoopFuture<Reservation> {
        let reservationID = try request.parameters.next(ID.self)
        return self.reservationRepository
            .find(by: reservationID.uuid)
            .unwrap(or: Abort(.noContent))
            .map { reservation in
                guard reservation.itemID == item.id else {
                    throw Abort(.noContent)
                }
                return reservation
            }
    }

}
