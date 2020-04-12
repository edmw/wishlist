import Foundation
import NIO

// MARK: CreateItem

public struct CreateItem: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
        public let notificationSending: NotificationSendingProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
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

    typealias ActorResult = (list: List, item: Item)

    internal let actor: () -> CreateItemActor & SetupItemActor

    internal init(actor: @escaping @autoclosure () -> CreateItemActor & SetupItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        in list: List,
        createWith values: ItemValues,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<ActorResult>
    {
        let actor = self.actor()
        let itemRepository = actor.itemRepository
        return try values.validate(for: list, using: itemRepository)
            .flatMap { values in
                // create item
                let item = try Item(for: list, from: values)
                return itemRepository
                    .save(item: item)
                    .setupItem(using: actor, in: .init(from: boundaries))
                    .map { item in
                        return (list: list, item: item)
                    }
            }
            .catchFlatMap { error in
                if let valuesError = error as? ValuesError<ItemValues> {
                    throw CreateItemValidationError(list: list, error: valuesError)
                }
                throw error
            }
    }

}

// MARK: -

protocol CreateItemActor {
    var itemRepository: ItemRepository { get }
    var favoriteService: FavoriteService { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

protocol CreateItemError: ActionError {
    var list: List { get }
}

struct CreateItemValidationError: CreateItemError {
    var list: List
    var error: ValuesError<ItemValues>
}

// MARK: - Actor

extension DomainUserItemsActor {

    // MARK: createItem

    public func createItem(
        _ specification: CreateItem.Specification,
        _ boundaries: CreateItem.Boundaries
    ) throws -> EventLoopFuture<CreateItem.Result> {
        let logging = self.logging
        let recording = self.recording
        let favoriteService = self.favoriteService
        let notificationSending = boundaries.notificationSending
        return try listRepository
            .findAndUser(by: specification.listID, for: specification.userID)
            .unwrap(or: UserItemsActorError.invalidList)
            .flatMap { list, user in
                return try CreateItem(actor: self)
                    .execute(in: list, createWith: specification.values, in: boundaries)
                    .logMessage(
                        .createItem(for: user, and: list), for: { $0.item }, using: logging
                    )
                    .recordEvent(
                        .createItem(for: user, and: list), for: { $0.item }, using: recording
                    )
                    .sendNotifications(
                        using: favoriteService, and: notificationSending
                    )
                    .map { list, item in
                        return .init(user, list, item)
                    }
                    .catchMap { error in
                        if let createError = error as? CreateItemValidationError {
                            logging.debug("Item creation validation error: \(createError)")
                            let list = createError.list.representation
                            let error = createError.error
                            throw UserItemsActorError
                                .validationError(user.representation, list, nil, error)
                        }
                        throw error
                    }
            }
    }

}

// MARK: -

extension SetupItem.Boundaries {

    init(from boundaries: CreateItem.Boundaries) {
        self.worker = boundaries.worker
        self.imageStore = boundaries.imageStore
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func createItem(for user: User, and list: List)
        -> LoggingMessageRoot<Item>
    {
        return .init({ item in
            LoggingMessage(label: "Create Item", subject: item, loggables: [user, list])
        })
    }

}

// MARK: Recording

extension RecordingEventRoot {

    fileprivate static func createItem(for user: User, and list: List)
        -> RecordingEventRoot<Item>
    {
        return .init({ item in
            RecordingEvent(.CREATEENTITY, subject: item, attributes: ["user": user, "list": list])
        })
    }

}

// MARK: sendNotifications

extension EventLoopFuture where Expectation == CreateItem.ActorResult {

    func sendNotifications(
        using favoriteService: FavoriteService,
        and notificationSending: NotificationSendingProvider
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { result in
            return try favoriteService.notifyUsers(
                for: result.list,
                using: notificationSending,
                on: self.eventLoop
            )
            .transform(to: result)
        }
    }

}
