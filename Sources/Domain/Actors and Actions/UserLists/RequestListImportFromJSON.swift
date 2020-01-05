import Foundation
import NIO

// MARK: ImportListFromJSON

public struct RequestListImportFromJSON: Action {

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

extension DomainUserListsActor {

    // MARK: requestListImport

    public func requestListImport(
        _ specification: RequestListImportFromJSON.Specification,
        _ boundaries: RequestListImportFromJSON.Boundaries
    ) throws -> EventLoopFuture<RequestListImportFromJSON.Result> {
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .map { user in .init(user) }
    }

}
