import Foundation
import NIO

// MARK: RequestSettingsEditing

public struct RequestSettingsEditing: Action {

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

extension DomainUserSettingsActor {

    // MARK: requestSettingsEditing

    public func requestSettingsEditing(
        _ specification: RequestSettingsEditing.Specification,
        _ boundaries: RequestSettingsEditing.Boundaries
    ) throws -> EventLoopFuture<RequestSettingsEditing.Result> {
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserSettingsActorError.invalidUser)
            .map { user in .init(user) }
    }

}
