import Foundation
import NIO

// MARK: CreateOrUpdateList

public struct CreateOrUpdateList: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID?
        public let values: ListValues
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        internal init(_ user: User, _ list: List) {
            self.user = user.representation
            self.list = list.representation
        }
        internal init(_ result: CreateList.Result) {
            self.user = result.user
            self.list = result.list
        }
        internal init(_ result: UpdateList.Result) {
            self.user = result.user
            self.list = result.list
        }
    }

}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: createOrUpdateList

    public func createOrUpdateList(
        _ specification: CreateOrUpdateList.Specification,
        _ boundaries: CreateOrUpdateList.Boundaries
    ) throws -> EventLoopFuture<CreateOrUpdateList.Result> {
        let userid = specification.userID
        let listvalues = specification.values
        if let listid = specification.listID {
            return try self.updateList(
                .specification(userBy: userid, listBy: listid, from: listvalues),
                .boundaries(worker: boundaries.worker)
            )
            .map { updateResult in .init(updateResult) }
        }
        else {
            return try self.createList(
                .specification(userBy: userid, from: listvalues),
                .boundaries(worker: boundaries.worker)
            )
            .map { createResult in .init(createResult) }
        }
    }

}
