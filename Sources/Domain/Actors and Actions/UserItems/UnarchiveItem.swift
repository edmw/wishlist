import Foundation
import NIO

// MARK: UnarchiveItem

public struct UnarchiveItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public let itemID: ItemID
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

    internal let actor: () -> UnarchiveItemActor

    internal init(actor: @escaping @autoclosure () -> UnarchiveItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        on item: Item,
        in list: List,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<Item>
    {
        let actor = self.actor()
        let itemRepository = actor.itemRepository
        guard item.id != nil else {
            throw EntityError<Item>.requiredIDMissing
        }
        item.archival = false
        return itemRepository.save(item: item)
    }

}

// MARK: -

protocol UnarchiveItemActor {
    var itemRepository: ItemRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: archiveItem

    public func unarchiveItem(
        _ specification: UnarchiveItem.Specification,
        _ boundaries: UnarchiveItem.Boundaries
    ) throws -> EventLoopFuture<ArchiveItem.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        return try self.listRepository
            .findAndUser(by: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .find(by: itemid, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item in
                        return try UnarchiveItem(actor: self)
                            .execute(on: item, in: list, in: boundaries)
                            .logMessage(.unarchiveItem(for: user, and: list), using: self.logging)
                            .map { item in
                                .init(user, list, item)
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func unarchiveItem(for user: User, and list: List)
        -> LoggingMessageRoot<Item>
    {
        return .init({ item in
            LoggingMessage(label: "Unarchive Item", subject: item, loggables: [user, list])
        })
    }

}
