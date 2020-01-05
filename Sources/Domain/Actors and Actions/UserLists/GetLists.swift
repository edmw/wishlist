import Foundation
import NIO

// MARK: GetLists

public final class GetLists: Action {

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
        public let sorting: ListsSorting
        public let includeItemsCount: Bool
        public static func specification(
            userBy userid: UserID,
            with sorting: ListsSorting = .ascending(by: \List.title),
            includeItemsCount: Bool = true
        ) -> Self {
            return Self(userID: userid, sorting: sorting, includeItemsCount: includeItemsCount)
        }
    }

    // MARK: Result

    public struct Result {
        public let user: UserRepresentation
        public let lists: [ListRepresentation]
        internal init(_ user: UserRepresentation, lists: [ListRepresentation]) {
            self.user = user
            self.lists = lists
        }
    }

}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: getLists

    public func getLists(
        _ specification: GetLists.Specification,
        _ boundaries: GetLists.Boundaries
    ) throws -> EventLoopFuture<GetLists.Result> {
        let worker = boundaries.worker
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try self.listRepresentationsBuilder
                    .reset()
                    .forUser(user)
                    .withSorting(specification.sorting)
                    .includeItemsCount(specification.includeItemsCount)
                    .build(on: worker)
                    .map { lists in .init(user.representation, lists: lists) }
            }
    }

}
