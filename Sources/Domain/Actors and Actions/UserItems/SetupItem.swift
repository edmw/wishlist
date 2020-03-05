import Foundation
import NIO

// MARK: SetupItem

public struct SetupItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let itemID: ItemID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let item: ItemRepresentation
        internal init(_ item: Item) {
            self.item = item.representation
        }
    }

}

// MARK: -

protocol SetupItemActor {
    var itemRepository: ItemRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: setupItem

    public func setupItem(
        _ specification: SetupItem.Specification,
        _ boundaries: SetupItem.Boundaries
    ) throws -> EventLoopFuture<SetupItem.Result> {
        return self.itemRepository
            .find(by: specification.itemID)
            .unwrap(or: UserItemsActorError.invalidItem)
            .setupItem(using: self, in: boundaries)
            .map { item in
                return .init(item)
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func deleteItem(with id: ItemID?) -> LoggingMessageRoot<Item> {
        return .init({ item in
            LoggingMessage(label: "Delete Item", subject: item, loggables: [id])
        })
    }

}

extension EventLoopFuture where Expectation == Item {

    func setupItem(using actor: SetupItemActor, in boundaries: SetupItem.Boundaries)
        -> EventLoopFuture<Item>
    {
        let itemRepository = actor.itemRepository
        let logging = actor.logging
        return self.flatMap(to: Item.self) { item in
            guard let imageURL = item.imageURL else {
                return boundaries.worker.makeSucceededFuture(item)
            }
            return try boundaries.imageStore.storeImage(for: item, from: imageURL)
                .flatMap { localImageURL in
                    guard let localImageURL = localImageURL else {
                        return boundaries.worker.makeSucceededFuture(item)
                    }
                    if let itemLocalImageURL = item.localImageURL,
                       itemLocalImageURL != localImageURL
                    {
                        try boundaries.imageStore.removeImage(at: itemLocalImageURL)
                    }
                    item.localImageURL = localImageURL
                    return itemRepository.save(item: item)
                }
                .catchMap { error in
                    logging.error("Error while setting up item: \(error)")
                    return item
                }
        }
    }

}
