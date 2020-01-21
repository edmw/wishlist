import DomainModel

import Foundation
import NIO

// MARK: PresentPublicly

/// Action to present publicly available information.
///
/// Does mostly nothing, but returns an `UserRepresentation` if a user id is specified. This can
/// be used to present different information for users.
public struct PresentPublicly: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID?
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation?
        internal init(_ user: User?) {
            self.user = user?.representation
        }
    }

}

// MARK: - Actor

extension DomainAnnouncementsActor {

    // MARK: presentPublicly

    public func presentPublicly(
        _ specification: PresentPublicly.Specification,
        _ boundaries: PresentPublicly.Boundaries
    ) throws -> EventLoopFuture<PresentPublicly.Result> {
        guard let userid = specification.userID else {
            return boundaries.worker.makeSucceededFuture(.init(nil))
        }
        return userRepository.find(id: userid)
            .unwrap(or: AnnouncementsActorError.invalidUser)
            .map { user in .init(user) }
    }

}
