import Foundation
import NIO

// MARK: GetInvitations

public final class GetInvitations: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
    }

    // MARK: Result

    public struct Result {
        public let user: UserRepresentation
        public let invitations: [InvitationRepresentation]
        internal init(_ user: UserRepresentation, invitations: [InvitationRepresentation]) {
            self.user = user
            self.invitations = invitations
        }
    }

}

// MARK: - Actor

extension DomainUserInvitationsActor {

    // MARK: getInvitations

    // Implementation (for documentation see UserInvitationsActor protocol)
    public func getInvitations(
        _ specification: GetInvitations.Specification,
        _ boundaries: GetInvitations.Boundaries
    ) throws -> EventLoopFuture<GetInvitations.Result> {
        let worker = boundaries.worker
        // find user and authorize access to invitations for user
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserInvitationsActorError.invalidUser)
            .authorize(on: Invitation.self)
            .flatMap { user in
                return try self.invitationRepresentationsBuilder
                    .reset()
                    .forUser(user)
                    .build(on: worker)
                    .map { invitations in
                        .init(user.representation, invitations: invitations)
                    }
            }
    }

}
