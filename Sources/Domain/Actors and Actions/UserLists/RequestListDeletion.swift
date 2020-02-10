import Foundation
import NIO

// MARK: RequestListDeletion

public struct RequestListDeletion: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        internal init(_ user: User, _ list: List) {
            self.user = user.representation
            self.list = list.representation
        }
    }

}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: requestListDeletion

    public func requestListDeletion(
        _ specification: RequestListDeletion.Specification,
        _ boundaries: RequestListDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestListDeletion.Result> {
        return try self.listRepository
            .findAndUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserListsActorError.invalidList)
            .map { list, user in
                .init(user, list)
            }
    }

}
