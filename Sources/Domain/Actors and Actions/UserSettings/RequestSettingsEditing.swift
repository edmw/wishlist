import Foundation
import NIO

// MARK: RequestSettingsEditing

public struct RequestSettingsEditing: Action {

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
