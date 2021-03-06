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

    internal let actor: () -> UpdateItemActor & SetupItemActor

    internal init(actor: @escaping @autoclosure () -> UpdateItemActor & SetupItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        on item: Item,
        in list: List,
        updateWith values: ItemValues,
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

// MARK: -

protocol UpdateItemActor {
    var itemRepository: ItemRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
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

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: updateItem

    public func updateItem(
        _ specification: UpdateItem.Specification,
        _ boundaries: UpdateItem.Boundaries
    ) throws -> EventLoopFuture<UpdateItem.Result> {
        let itemRepository = self.itemRepository
        let logging = self.logging
        return try itemRepository
            .findAndListAndUser(
                by: specification.itemID,
                in: specification.listID,
                for: specification.userID
            )
            .unwrap(or: UserItemsActorError.invalidItem)
            .flatMap { item, list, user in
                let itemvalues = specification.values
                return try UpdateItem(actor: self)
                    .execute(on: item, in: list, updateWith: itemvalues, in: boundaries)
                    .logMessage(
                        .updateItem(for: user, and: list), for: { $0.1 }, using: logging
                    )
                    .map { list, item in
                        .init(user, list, item)
                    }
                    .catchMap { error in
                        if let updateError = error as? UpdateItemValidationError {
                            logging.debug("Item updating validation error: \(updateError)")
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

// MARK: -

extension SetupItem.Boundaries {

    init(from boundaries: UpdateItem.Boundaries) {
        self.worker = boundaries.worker
        self.imageStore = boundaries.imageStore
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func updateItem(for user: User, and list: List) -> LoggingMessageRoot<Item> {
        return .init({ item in
            LoggingMessage(label: "Update Item", subject: item, loggables: [user, list])
        })
    }

}
