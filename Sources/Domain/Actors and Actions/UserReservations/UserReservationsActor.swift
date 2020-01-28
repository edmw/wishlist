import Foundation
import NIO

// MARK: UserReservationsActor

/// Reservations use cases for the user.
public protocol UserReservationsActor: Actor {

    func requestReservationDeletion(
        _ specification: RequestReservationDeletion.Specification,
        _ boundaries: RequestReservationDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestReservationDeletion.Result>

    func deleteReservation(
        _ specification: DeleteReservation.Specification,
        _ boundaries: DeleteReservation.Boundaries
    ) throws -> EventLoopFuture<DeleteReservation.Result>

}

/// Errors thrown by the User Reservations actor.
enum UserReservationsActorError: Error {
    case invalidItem
    case invalidReservation
}

/// This is the domain’s implementation of the Reservations use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserReservationsActor: UserReservationsActor {

    let itemRepository: ItemRepository
    let reservationRepository: ReservationRepository

    let logging: MessageLogging
    let recording: EventRecording

    public required init(
        itemRepository: ItemRepository,
        reservationRepository: ReservationRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.itemRepository = itemRepository
        self.reservationRepository = reservationRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
    }

}
