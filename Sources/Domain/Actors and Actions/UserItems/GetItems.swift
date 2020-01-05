import Foundation
import NIO

// MARK: GetItems

public final class GetItems: Action {

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
        public let sorting: ItemsSorting
        public static func specification(
            userBy userid: UserID,
            listBy listid: ListID,
            with sorting: ItemsSorting = .ascending(by: \Item.title)
        ) -> Self {
            return Self(
                userID: userid,
                listID: listid,
                sorting: sorting
            )
        }
    }

    // MARK: Result

    public struct Result {
        public let user: UserRepresentation
        public let list: ListRepresentation
        public let items: [ItemRepresentation]
        internal init(
            _ user: UserRepresentation,
            _ list: ListRepresentation,
            items: [ItemRepresentation]
        ) {
            self.user = user
            self.list = list
            self.items = items
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: getItems

    public func getItems(
        _ specification: GetItems.Specification,
        _ boundaries: GetItems.Boundaries
    ) throws -> EventLoopFuture<GetItems.Result> {
        let worker = boundaries.worker
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserItemsActorError.invalidUser)
            .flatMap { user in
                return try self.listRepository
                    .find(by: specification.listID, for: user)
                    .unwrap(or: UserItemsActorError.invalidList)
                    .flatMap { list in
                        return try self.itemRepresentationsBuilder
                            .reset()
                            .forList(list)
                            .withSorting(specification.sorting)
                            .build(on: worker)
                            .map { items in
                                .init(user.representation, list.representation, items: items)
                            }
                    }
            }
    }

}
