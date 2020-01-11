import Foundation
import NIO

// MARK: UpdateItem

public struct UpdateItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID
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
    }

    // MARK: -

    internal let actor: () -> UpdateItemActor & CreateItemActor

    internal init(actor: @escaping @autoclosure () -> UpdateItemActor & CreateItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        on item: Item,
        with values: ItemValues,
        in list: List,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<(list: List, item: Item)>
    {
        let actor = self.actor()
        let itemRepository = actor.itemRepository
        return try values.validate(for: list, this: item, using: itemRepository)
            .flatMap { values in
                // update item
                try item.update(for: list, from: values)
                item.modifiedAt = Date()
                return itemRepository
                    .save(item: item)
                    .setupItem(using: actor, in: .init(from: boundaries))
                    .map { item in
                        return (list: list, item: item)
                    }
            }
            .catchFlatMap { error in
                if let valuesError = error as? ValuesError<ItemValues> {
                    throw UpdateItemValidationError(list: list, item: item, error: valuesError)
                }
                throw error
            }
    }

}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: updateItem

    public func updateItem(
        _ specification: UpdateItem.Specification,
        _ boundaries: UpdateItem.Boundaries
    ) throws -> EventLoopFuture<UpdateItem.Result> {
        return try self.listRepository
            .findWithUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .find(by: specification.itemID, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item in
                        let itemvalues = specification.values
                        return try UpdateItem(actor: self)
                            .execute(on: item, with: itemvalues, in: list, in: boundaries)
                            .logMessage("updated", using: self.logging)
                            .map { list, item in
                                .init(user, list, item)
                            }
                            .catchMap { error in
                                if let updateError = error as? UpdateItemValidationError {
                                    self.logging.debug(
                                        "Item updating validation error: \(updateError)"
                                    )
                                    throw UserItemsActorError.validationError(
                                        user.representation,
                                        updateError.list.representation,
                                        updateError.item.representation,
                                        updateError.error
                                    )
                                }
                                throw error
                            }
                    }
            }
    }

}

// MARK: -

protocol UpdateItemActor {
    var itemRepository: ItemRepository { get }
    var logging: MessageLoggingProvider { get }
    var recording: EventRecordingProvider { get }
}

protocol UpdateItemError: ActionError {
    var list: List { get }
    var item: Item { get }
}

struct UpdateItemInvalidOwnerError: UpdateItemError {
    var list: List
    var item: Item
}

struct UpdateItemValidationError: UpdateItemError {
    var list: List
    var item: Item
    var error: ValuesError<ItemValues>
}

// MARK: -

extension CreateItem.Boundaries {

    init(from boundaries: UpdateItem.Boundaries) {
        self.worker = boundaries.worker
        self.imageStore = boundaries.imageStore
    }

}
