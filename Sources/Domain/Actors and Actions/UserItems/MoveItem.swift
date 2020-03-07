import Foundation
import NIO

// MARK: MoveItem

public struct MoveItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID
        public let targetListID: ListID
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

    internal let actor: () -> MoveItemActor

    internal init(actor: @escaping @autoclosure () -> MoveItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        on item: Item,
        in list: List,
        moveTo targetlist: List,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<(list: List, item: Item)>
    {
        let actor = self.actor()
        let itemRepository = actor.itemRepository
        guard let targetlistid = targetlist.id else {
            throw EntityError<List>.requiredIDMissing
        }
        item.listID = targetlistid
        return itemRepository
            .save(item: item)
            .map { item in
                return (list: targetlist, item: item)
            }
    }

}

// MARK: -

protocol MoveItemActor {
    var itemRepository: ItemRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: updateItem

    public func moveItem(
        _ specification: MoveItem.Specification,
        _ boundaries: MoveItem.Boundaries
    ) throws -> EventLoopFuture<MoveItem.Result> {
        return try self.listRepository
            .findAndUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .findWithReservation(by: specification.itemID, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item, reservation in
                        guard reservation == nil else {
                            // reserved items can not be moved
                            throw UserItemsActorError.itemIsReserved
                        }
                        return try self.listRepository
                            .find(by: specification.targetListID, for: user)
                            .unwrap(or: UserItemsActorError.invalidList)
                            .flatMap { targetlist in
                                return try MoveItem(actor: self)
                                    .execute(on: item, in: list, moveTo: targetlist, in: boundaries)
                                    .logMessage(
                                        .moveItem(for: user, and: list),
                                        for: { $0.1 },
                                        using: self.logging
                                    )
                                    .map { list, item in
                                        .init(user, list, item)
                                    }
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func moveItem(for user: User, and list: List) -> LoggingMessageRoot<Item> {
        return .init({ item in
            LoggingMessage(label: "Move Item", subject: item, loggables: [user, list])
        })
    }

}
