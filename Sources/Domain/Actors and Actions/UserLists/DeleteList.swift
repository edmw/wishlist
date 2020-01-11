import Foundation
import NIO

// MARK: DeleteList

public struct DeleteList: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
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

    // MARK: deleteList

    public func deleteList(
        _ specification: DeleteList.Specification,
        _ boundaries: DeleteList.Boundaries
    ) throws -> EventLoopFuture<DeleteList.Result> {
        let userid = specification.userID
        let listid = specification.listID
        return try self.listRepository
            .findWithUser(by: listid, for: userid)
            .unwrap(or: UserListsActorError.invalidList)
            .flatMap { arguments in let (list, user) = arguments
                // delete items of list
                return try self.itemService
                    .deleteItems(for: list, imageStore: boundaries.imageStore)
                    .transformError(
                        when: ItemServiceError.deleteItemsHasReservedItems,
                        then: UserListsActorError.listHasReservedItems
                    )
                    .logMessage("items deleted", using: self.logging)
                    .flatMap { _ in
                        self.logging.message(for: list, with: "deleting")
                        // delete list
                        return try self.listRepository
                            .delete(list: list, for: user)
                            .unwrap(or: UserListsActorError.invalidList)
                            .logMessage("deleted", using: self.logging)
                            .recordEvent("deleted for \(user)", using: self.recording)
                            .map { _ in
                                .init(user)
                            }
                    }
            }
    }

}
