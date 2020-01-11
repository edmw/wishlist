import Foundation
import NIO

// MARK: CreateOrUpdateItem

public struct CreateOrUpdateItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID?
        public let values: ItemValues
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        public let item: ItemRepresentation
        internal init(_ user: User, _ list: List, _ item: Item) {
            self.user = user.representation
            self.list = list.representation
            self.item = item.representation
        }
        internal init(_ result: CreateItem.Result) {
            self.user = result.user
            self.list = result.list
            self.item = result.item
        }
        internal init(_ result: UpdateItem.Result) {
            self.user = result.user
            self.list = result.list
            self.item = result.item
        }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: createOrUpdateItem

    public func createOrUpdateItem(
        _ specification: CreateOrUpdateItem.Specification,
        _ boundaries: CreateOrUpdateItem.Boundaries
    ) throws -> EventLoopFuture<CreateOrUpdateItem.Result> {
        let userid = specification.userID
        let listid = specification.listID
        let itemvalues = specification.values
        if let itemid = specification.itemID {
            return try self.updateItem(
                .specification(userBy: userid, listBy: listid, itemBy: itemid, from: itemvalues),
                .boundaries(worker: boundaries.worker, imageStore: boundaries.imageStore)
            )
            .map { updateResult in .init(updateResult) }
        }
        else {
            return try self.createItem(
                .specification(userBy: userid, listBy: listid, from: itemvalues),
                .boundaries(worker: boundaries.worker, imageStore: boundaries.imageStore)
            )
            .map { createResult in .init(createResult) }
        }
    }

}
