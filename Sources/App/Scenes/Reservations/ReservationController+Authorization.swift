import Vapor

// MARK: ReservationController

extension ReservationController {

    func authorizeList(
        on request: Request,
        _ function: @escaping (Identification, List) throws -> EventLoopFuture<Response>
    ) throws -> EventLoopFuture<Response> {

        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        // get list from request
        return try self.requireList(on: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try self.requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        // execute the given function after authorization
                        return try function(identification, list)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    func authorizeReservation(
        on request: Request,
        with identification: Identification,
        _ function: @escaping (Reservation) throws -> EventLoopFuture<Response>
    ) throws -> EventLoopFuture<Response> {

        // get reservation from request
        return try requireReservation(on: request)
            .flatMap { reservation in

                // check if the found reservation belongs to the given identification
                guard reservation.holder == identification else {
                    throw Abort(.notFound)
                }

                // execute the given function after authorization
                return try function(reservation)
            }
    }

}
