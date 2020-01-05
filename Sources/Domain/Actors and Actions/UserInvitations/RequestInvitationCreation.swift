import Foundation
import NIO

// MARK: RequestInvitationCreation

public struct RequestInvitationCreation: Action {

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
        internal init(_ user: User) {
            self.user = user.representation
        }
    }

}

// MARK: - Actor

extension DomainUserInvitationsActor {

    // MARK: requestInvitationCreation

    public func requestInvitationCreation(
        _ specification: RequestInvitationCreation.Specification,
        _ boundaries: RequestInvitationCreation.Boundaries
    ) throws -> EventLoopFuture<RequestInvitationCreation.Result> {
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .authorize(on: Invitation.self)
            .map { user in
                .init(user)
            }
    }

}
