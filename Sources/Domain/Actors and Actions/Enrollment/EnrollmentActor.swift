import Foundation
import NIO

// MARK: EnrollmentActor

/// Enrollment use cases.
public protocol EnrollmentActor: Actor {

    /// Materialises a user.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: If the described subject is not eligible as user.
    ///
    /// This action returns a user or creates a new user if the described subject is eligible.
    /// Existing user will be updated with the values provided. If an invitation is given the
    /// invitation will be redeemed for the materialised user. When there are any reservations
    /// made as anonymous guest, these reservations will be transfered to the materialised user
    /// if the guest identification is provided.
    ///
    /// Possible options for this action are: Is it allowed to create new users? Do new user
    /// require an invitation to be created?
    ///
    /// **Specification:**
    /// - `options`: Options for the materialisation (defaults to `createUsers`).
    /// - `userIdentity`: Identity of the subject.
    /// - `userIdentityProvider`: Provider of the identity of the subject.
    /// - `userValues`: Description of the user subject.
    /// - `invitationCode`: Invitation code if an invitation code is available
    ///                     (defaults to `nil`).
    /// - `guestIdentification`: Guest identification if a guest identification is available
    ///                          (defaults to `nil`).
    ///
    /// **Boundaries:**
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result: ActionResult {
    ///    let user: UserRepresentation
    /// }
    /// ```
    func materialiseUser(
        _ specification: MaterialiseUser.Specification,
        _ boundaries: MaterialiseUser.Boundaries
    ) throws -> EventLoopFuture<MaterialiseUser.Result>

}

/// This is the domain’s implementation of the Enrollment use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainEnrollmentActor: EnrollmentActor {

    let userRepository: UserRepository
    let invitationRepository: InvitationRepository
    let reservationRepository: ReservationRepository

    let logging: MessageLogging
    let recording: EventRecording

    let userService: UserService
    let invitationService: InvitationService
    let reservationService: ReservationService

    public required init(
        userRepository: UserRepository,
        invitationRepository: InvitationRepository,
        reservationRepository: ReservationRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.invitationRepository = invitationRepository
        self.userRepository = userRepository
        self.reservationRepository = reservationRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
        self.userService = UserService(userRepository)
        self.invitationService = InvitationService(invitationRepository)
        self.reservationService = ReservationService(reservationRepository, userRepository)
    }

}
