import DomainModel

import Foundation
import NIO

// MARK: RequestProfileEditing

public struct RequestProfileEditing: Action {

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

extension DomainUserProfileActor {

    // MARK: requestProfileEditing

    public func requestProfileEditing(
        _ specification: RequestProfileEditing.Specification,
        _ boundaries: RequestProfileEditing.Boundaries
    ) throws -> EventLoopFuture<RequestProfileEditing.Result> {
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .map { user in
                .init(user)
            }
    }

}
