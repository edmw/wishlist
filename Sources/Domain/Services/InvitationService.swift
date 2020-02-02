import Foundation
import NIO

struct InvitationService {

    /// Repository for Invitations to be used by this service.
    private let invitationRepository: InvitationRepository

    /// Initializes an Invitation service.
    /// - Parameter invitationRepository: Repository for Invitations to be used by this service.
    init(_ invitationRepository: InvitationRepository) {
        self.invitationRepository = invitationRepository
    }

    /// Accepts an invitation.
    ///
    /// Checks if the invitation is still open, changes the status to accepted and links the given
    /// user to the invitation.
    /// - Parameter invitation: Invitation to accept.
    /// - Parameter user: User which accepts the invitation.
    /// - Throws: If the invitation status is invalid.
    func acceptInvitation(
        _ invitation: Invitation,
        for user: User
    ) throws -> EventLoopFuture<Invitation> {
        guard invitation.status == .open else {
            throw InvitationServiceError.acceptInvitationInvalidStatus(invitation)
        }
        invitation.inviteeID = user.id
        invitation.status = .accepted
        return invitationRepository.save(invitation: invitation)
    }

    /// Revokes an invitation.
    ///
    /// Checks if the invitation is still open and changes the status to revoked.
    /// - Parameter invitation: Invitation to revoke.
    /// - Throws: If the invitation status is invalid.
    func revokeInvitation(_ invitation: Invitation) throws -> EventLoopFuture<Invitation> {
        guard invitation.status == .open else {
            throw InvitationServiceError.revokeInvitationInvalidStatus(invitation)
        }
        invitation.status = .revoked
        return invitationRepository.save(invitation: invitation)
    }

}

/// Errors thrown by the Invitation Service.
enum InvitationServiceError: Error {
    /// An Invitation can be accept if it‘s status is `open`, only.
    case acceptInvitationInvalidStatus(Invitation)
    /// An Invitation can be revoked if it‘s status is `open`, only.
    case revokeInvitationInvalidStatus(Invitation)
}
