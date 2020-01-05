import Foundation
import NIO

struct ReservationService {

    /// Repository for Reservations to be used by this service.
    let reservationRepository: ReservationRepository
    /// Repository for Users to be used by this service.
    let userRepository: UserRepository

    /// Initializes an Reservation service.
    /// - Parameter reservationRepository: Repository for Reservations to be used by this service.
    /// - Parameter userRepository: Repository for Users to be used by this service.
    init(_ reservationRepository: ReservationRepository, _ userRepository: UserRepository) {
        self.reservationRepository = reservationRepository
        self.userRepository = userRepository
    }

    /// Transfers reservations associated with the specified `Identification` to the specified user.
    /// Does nothing if the specified identification is already attached to a user.
    /// - Parameter identification: Identification which holds the reservations.
    /// - Parameter user: User to whom the reservations will be transfered to.
    func transferReservations(
        from identification: Identification,
        to user: User
    ) throws -> EventLoopFuture<Void> {
        return self.userRepository
            .find(identification: identification)
            .flatMap { result in
                guard result == nil else {
                    // identification is attached to another user,
                    // just ignore it (actually this should not happen)
                    return self.reservationRepository.future(())
                }
                // identification is not attached to another user,
                // transfer (maybe existing) reservations
                return self.reservationRepository
                    .transfer(from: identification, to: user.identification)
            }
    }

}
