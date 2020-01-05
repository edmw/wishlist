import Foundation
import NIO

// MARK: RequestListEditing

public struct RequestListEditing: Action {

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
        public let listID: ListID?
        public static func specification(userBy userid: UserID, listBy listid: ListID?) -> Self {
            return Self(userID: userid, listID: listid)
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation?
        internal init(_ user: User, _ list: List? = nil) {
            self.user = user.representation
            self.list = list?.representation
        }
    }

}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: requestListEditing

    public func requestListEditing(
        _ specification: RequestListEditing.Specification,
        _ boundaries: RequestListEditing.Boundaries
    ) throws -> EventLoopFuture<RequestListEditing.Result> {
        let worker = boundaries.worker
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                if let listID = specification.listID {
                    return try self.listRepository
                        .find(by: listID, for: user)
                        .unwrap(or: UserListsActorError.invalidList)
                        .map { list in
                            .init(user, list)
                        }
                }
                else {
                    return worker.makeSucceededFuture(.init(user))
                }
            }
    }

}
