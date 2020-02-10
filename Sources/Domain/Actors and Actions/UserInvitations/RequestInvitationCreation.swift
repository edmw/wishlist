import Foundation
import NIO

// MARK: RequestInvitationCreation

public struct RequestInvitationCreation: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
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

    // Implementation (for documentation see UserInvitationsActor protocol)
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
