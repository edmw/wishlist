import Foundation
import NIO

// MARK: ArchiveItem

public struct ArchiveItem: Action {

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

    internal let actor: () -> ArchiveItemActor

    internal init(actor: @escaping @autoclosure () -> ArchiveItemActor) {
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
        item.archival = true
        return itemRepository.save(item: item)
    }

}

// MARK: -

protocol ArchiveItemActor {
    var itemRepository: ItemRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: archiveItem

    public func archiveItem(
        _ specification: ArchiveItem.Specification,
        _ boundaries: ArchiveItem.Boundaries
    ) throws -> EventLoopFuture<ArchiveItem.Result> {
        let itemid = specification.itemID
        let listid = specification.listID
        let userid = specification.userID
        return try self.listRepository
            .findAndUser(by: listid, for: userid)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try self.itemRepository
                    .findWithReservation(by: itemid, in: list)
                    .unwrap(or: UserItemsActorError.invalidItem)
                    .flatMap { item, reservation in
                        guard item.archivable(given: reservation)
                            else {
                                throw UserItemsActorError.itemNotArchivable
                            }
                        return try ArchiveItem(actor: self)
                            .execute(on: item, in: list, in: boundaries)
                            .logMessage(.archiveItem(for: user, and: list), using: self.logging)
                            .map { item in
                                .init(user, list, item)
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func archiveItem(for user: User, and list: List)
        -> LoggingMessageRoot<Item>
    {
        return .init({ item in
            LoggingMessage(label: "Archive Item", subject: item, loggables: [user, list])
        })
    }

}
