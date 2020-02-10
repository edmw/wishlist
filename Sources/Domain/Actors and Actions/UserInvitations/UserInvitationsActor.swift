import Foundation
import NIO

// MARK: UserInvitationsActor

/// Invitations use cases for the user.
public protocol UserInvitationsActor: Actor {

    /// Gets all invitations for the specified user.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user is entitled to issue invitations and throws an
    /// authorization error otherwise.
    ///
    /// Specification:
    /// - `userID`: ID of the user to create the invitation for.
    ///
    /// Boundaries:
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result {
    ///     let user: UserRepresentation
    ///     let invitations: [InvitationRepresentation]
    /// }
    /// ```
    func getInvitations(
        _ specification: GetInvitations.Specification,
        _ boundaries: GetInvitations.Boundaries
    ) throws -> EventLoopFuture<GetInvitations.Result>

    /// Requests the creation of an invitation.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user is entitled to issue invitations and throws an
    /// authorization error otherwise.
    ///
    /// **Specification:**
    /// - `userID`: ID of the user to create the invitation for.
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
    func requestInvitationCreation(
        _ specification: RequestInvitationCreation.Specification,
        _ boundaries: RequestInvitationCreation.Boundaries
    ) throws -> EventLoopFuture<RequestInvitationCreation.Result>

    /// Creates an invitation.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user is entitled to issue invitations and throws an
    /// authorization error otherwise.
    ///
    /// **Specification:**
    /// - `userID`: ID of the user to create the invitation for.
    /// - `invitationValues`: Data for the invitation to create.
    /// - `sendMail`: True, if an invitation email should be sent.
    ///
    /// **Boundaries:**
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result: ActionResult {
    ///    let user: UserRepresentation
    ///    let invitation: InvitationRepresentation
    /// }
    /// ```
    func createInvitation(
        _ specification: CreateInvitation.Specification,
        _ boundaries: CreateInvitation.Boundaries
    ) throws -> EventLoopFuture<CreateInvitation.Result>

    /// Requests the revocation of an invitation.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user is entitled to issue invitations and ensures the specified
    /// invitation is owned by the user. Throws an authorization error otherwise.
    ///
    /// **Specification:**
    /// - `userID`: ID of the user to create the invitation for.
    /// - `invitationID`: ID of the invitation to revoke.
    ///
    /// **Boundaries:**
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result: ActionResult {
    ///    let user: UserRepresentation
    ///    let invitation: InvitationRepresentation
    /// }
    /// ```
    func requestInvitationRevocation(
        _ specification: RequestInvitationRevocation.Specification,
        _ boundaries: RequestInvitationRevocation.Boundaries
    ) throws -> EventLoopFuture<RequestInvitationRevocation.Result>

    /// Revokes an invitation.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user is entitled to issue invitations and ensures the specified
    /// invitation is owned by the user. Throws an authorization error otherwise. Only invitations
    /// which are neither accepted, declined or already revoked can be revoked.
    ///
    /// **Specification:**
    /// - `userID`: ID of the user to create the invitation for.
    /// - `invitationID`: ID of the invitation to revoke.
    ///
    /// **Boundaries:**
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result: ActionResult {
    ///    let user: UserRepresentation
    ///    let invitation: InvitationRepresentation
    /// }
    /// ```
    func revokeInvitation(
        _ specification: RevokeInvitation.Specification,
        _ boundaries: RevokeInvitation.Boundaries
    ) throws -> EventLoopFuture<RevokeInvitation.Result>

    /// Sends an invitation email.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user is entitled to issue invitations and ensures the specified
    /// invitation is owned by the user. Throws an authorization error otherwise. Mails can be sent
    /// for invitations which are in state open, only.
    ///
    /// **Specification:**
    /// - `userID`: ID of the user to create the invitation for.
    /// - `invitationID`: ID of the invitation to revoke.
    ///
    /// **Boundaries:**
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result: ActionResult {
    ///    let user: UserRepresentation
    ///    let invitation: InvitationRepresentation
    /// }
    /// ```
    func sendInvitationEmail(
        _ specification: SendInvitationEmail.Specification,
        _ boundaries: SendInvitationEmail.Boundaries
    ) throws -> EventLoopFuture<SendInvitationEmail.Result>

}

/// Errors thrown by the User Invitations actor.
public enum UserInvitationsActorError: Error {
    case invalidUser
    case invalidInvitation
    case invalidInvitationStatus(Invitation.Status)
    case validationError(
        UserRepresentation,
        InvitationRepresentation?,
        ValuesError<InvitationValues>
    )
}

/// This is the domain’s implementation of the Invitations use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserInvitationsActor: UserInvitationsActor,
    CreateInvitationActor
{
    let invitationRepository: InvitationRepository
    let userRepository: UserRepository

    let logging: MessageLogging
    let recording: EventRecording

    let invitationService: InvitationService

    let invitationRepresentationsBuilder: InvitationRepresentationsBuilder

    public required init(
        invitationRepository: InvitationRepository,
        userRepository: UserRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.invitationRepository = invitationRepository
        self.userRepository = userRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
        self.invitationService = InvitationService(invitationRepository)
        self.invitationRepresentationsBuilder
            = InvitationRepresentationsBuilder(invitationRepository)
    }

}
