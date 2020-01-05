import Domain

import Vapor

// MARK: ReservationParameterAcceptor

protocol ReservationParameterAcceptor {

    func reservationID(on request: Request) throws -> ReservationID?

    func requireReservationID(on request: Request) throws -> ReservationID

}

extension ItemParameterAcceptor where Self: Controller {

    /// Returns the reservation id given in the request’s route or nil if there is none.
    /// Asumes that the reservation id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func reservationID(on request: Request) throws -> ReservationID? {
        guard request.parameters.values.isNotEmpty else {
            return nil
        }
        return try ReservationID(request.parameters.next(ID.self))
    }

    /// Returns the reservation id given in the request’s route. Throws if there is none.
    /// Asumes that the reservation id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func requireReservationID(on request: Request) throws -> ReservationID {
        return try ReservationID(request.parameters.next(ID.self))
    }

}
