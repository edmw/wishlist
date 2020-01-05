import Foundation
import NIO

// MARK: RequestListDeletion

public struct RequestListDeletion: Action {

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
        public let listID: ListID
        public static func specification(userBy userid: UserID, listBy listid: ListID) -> Self {
            return Self(userID: userid, listID: listid)
        }
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
            .findWithUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserListsActorError.invalidList)
            .map { list, user in
                .init(user, list)
            }
    }

}
