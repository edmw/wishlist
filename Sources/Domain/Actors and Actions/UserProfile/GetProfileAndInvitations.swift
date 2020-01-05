import Foundation
import NIO

// MARK: GetProfileAndInvitations

public final class GetProfileAndInvitations: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public static func boundaries(worker: EventLoop) -> Self {
            return Self(worker: worker)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public static func specification(userBy userid: UserID) -> Self {
            return Self(userID: userid)
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let invitations: [InvitationRepresentation]?
        internal init(_ user: User, invitations: [InvitationRepresentation]? = nil) {
            self.user = user.representation
            self.invitations = invitations
        }
    }

}

// MARK: - Actor

extension DomainUserProfileActor {

    // MARK: getProfileAndInvitations

    public func getProfileAndInvitations(
        _ specification: GetProfileAndInvitations.Specification,
        _ boundaries: GetProfileAndInvitations.Boundaries
    ) throws -> EventLoopFuture<GetProfileAndInvitations.Result> {
        let worker = boundaries.worker
        // find user and authorize access to invitations for user
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserInvitationsActorError.invalidUser)
            .flatMap { user in
                do {
                    try user.authorize(on: Invitation.self)
                }
                catch {
                    return worker.makeSucceededFuture(.init(user))
                }
                return try self.invitationRepresentationsBuilder
                    .reset()
                    .forUser(user)
                    .build(on: worker)
                    .map { invitations in
                        .init(user, invitations: invitations)
                    }
            }
    }

}
