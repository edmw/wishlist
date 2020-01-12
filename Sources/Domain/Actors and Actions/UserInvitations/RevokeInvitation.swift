import Foundation
import NIO

// MARK: RevokeInvitation

public struct RevokeInvitation: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let invitationID: InvitationID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let invitation: InvitationRepresentation
        internal init(_ user: User, _ invitation: Invitation) {
            self.user = user.representation
            self.invitation = invitation.representation
        }
    }

}

// MARK: - Actor

extension DomainUserInvitationsActor {

    // MARK: revokeInvitation

    public func revokeInvitation(
        _ specification: RevokeInvitation.Specification,
        _ boundaries: RevokeInvitation.Boundaries
    ) throws -> EventLoopFuture<RevokeInvitation.Result> {
        let logging = self.logging
        let invitationRepository = self.invitationRepository
        // find user and authorize access to invitations for user
        // IMPROVEMENT: lookup both, invitation and user and authorize for user
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserInvitationsActorError.invalidUser)
            .authorize(on: Invitation.self)
            .flatMap { user in
                // find invitation and authorize access to this invitation for user
                return try invitationRepository.find(by: specification.invitationID)
                    .unwrap(or: UserInvitationsActorError.invalidInvitation)
                    .authorize(in: invitationRepository, for: user)
                    .flatMap { authorization in
                        let invitation = authorization.entity
                        return try self.invitationService
                            .revokeInvitation(invitation)
                            .logMessage(.revokeInvitation, using: logging)
                            .map { invitation in .init(user, invitation) }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    static var revokeInvitation: Self {
        return Self({ subject in
            LoggingMessage(label: "Revoke Invitation", subject: subject, attributes: [])
        })
    }

}
