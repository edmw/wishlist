import Foundation
import NIO

// MARK: RequestInvitationRevocation

public struct RequestInvitationRevocation: Action {

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

    // MARK: requestInvitationRevocation

    // Implementation (for documentation see UserInvitationsActor protocol)
    public func requestInvitationRevocation(
        _ specification: RequestInvitationRevocation.Specification,
        _ boundaries: RequestInvitationRevocation.Boundaries
    ) throws -> EventLoopFuture<RequestInvitationRevocation.Result> {
        let invitationRepository = self.invitationRepository
        // find user and authorize access to invitations for user
        // IMPROVEMENT: lookup both, invitation and user and authorize for user
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserInvitationsActorError.invalidUser)
            .authorize(on: Invitation.self)
            .flatMap { user in
                // find invitation and authorize access to this invitation for user
                return try invitationRepository
                    .find(by: specification.invitationID)
                    .unwrap(or: UserInvitationsActorError.invalidInvitation)
                    .authorize(in: invitationRepository, for: user)
                    .map { authorization in
                        let invitation = authorization.entity
                        guard invitation.status != .revoked else {
                            throw UserInvitationsActorError
                                .invalidInvitationStatus(invitation.status)
                        }
                        return .init(user, invitation)
                    }
            }
    }

}
