import Foundation
import NIO

// MARK: RequestListEditing

public struct RequestListEditing: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID?
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
