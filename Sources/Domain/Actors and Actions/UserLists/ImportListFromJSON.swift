import Foundation
import NIO

// MARK: ImportListFromJSON

public struct ImportListFromJSON: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let json: String
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        internal init(_ user: User, _ list: List) {
            self.user = user.representation
            self.list = list.representation
        }
    }

    // MARK: -

    internal let actor: () -> ImportListFromJSONActor & SetupItemActor

    internal init(actor: @escaping @autoclosure () -> ImportListFromJSONActor & SetupItemActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(with json: String, for user: User, in boundaries: Boundaries) throws
        -> EventLoopFuture<List>
    {
        let actor = self.actor()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let values = try decoder.decode(ListValues.self, from: Data(json.utf8))

        let listRepository = actor.listRepository
        return try listRepository
            .available(title: values.title, for: user)
            .unwrap(or: ImportListFromJSONListNameError(user: user))
            .flatMap { titleString in
                let title = Title(titleString)
                return try self.store(values.with(title: title), for: user, on: boundaries)
            }
            .catchFlatMap { error in
                if let entityError = error as? AnyEntityError {
                    throw ImportListFromJSONValidationError(error: entityError)
                }
                throw error
            }
    }

    /// Stores the given list values into a new list.
    /// Values must pass properties validation and constraints check.
    private func store(
        _ listvalues: ListValues,
        for user: User,
        on boundaries: Boundaries
    ) throws -> EventLoopFuture<List> {
        let actor = self.actor()
        let listRepository = actor.listRepository
        return try listvalues.validate(for: user, using: listRepository)
            .flatMap { values in
                // create list
                let list = try List(for: user, from: values)
                return listRepository
                    .save(list: list)
                    .flatMap { list in
                        var futureItems = [EventLoopFuture<Item>]()
                        // store items
                        for itemvalues in values.items ?? [] {
                            futureItems.append(
                                try self.store(itemvalues, for: list, on: boundaries)
                            )
                        }
                        return futureItems.flatten(on: boundaries.worker)
                            .transform(to: list)
                    }
            }
    }

    /// Stores the given item values into a new item.
    /// Values must pass properties validation and constraints check.
    private func store(
        _ itemvalues: ItemValues,
        for list: List,
        on boundaries: Boundaries
    ) throws -> EventLoopFuture<Item> {
        let actor = self.actor()
        let itemRepository = actor.itemRepository
        return try itemvalues.validate(for: list, using: itemRepository)
            .flatMap { values in
                // create item
                let item = try Item(for: list, from: values)
                return itemRepository
                    .save(item: item)
                    .setupItem(using: actor, in: .init(from: boundaries))
                    .transform(to: item)
            }
    }

}

// MARK: -

protocol ImportListFromJSONActor {
    var listRepository: ListRepository { get }
    var itemRepository: ItemRepository { get }
    var logging: MessageLogging { get }
}

protocol ImportListFromJSONError: ActionError {
}

struct ImportListFromJSONListNameError: ImportListFromJSONError {
    var user: User
}

struct ImportListFromJSONValidationError: ImportListFromJSONError {
    var error: AnyEntityError
}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: importList

    public func importList(
        _ specification: ImportListFromJSON.Specification,
        _ boundaries: ImportListFromJSON.Boundaries
    ) throws -> EventLoopFuture<ImportListFromJSON.Result> {
        let userRepository = self.userRepository
        let logging = self.logging
        let recording = self.recording
        return userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try ImportListFromJSON(actor: self)
                    .execute(with: specification.json, for: user, in: boundaries)
                    .logMessage(.importList(for: user), using: logging)
                    .recordEvent(.importList(for: user), using: recording)
                    .map { list in
                        .init(user, list)
                    }
                    .catchMap { error in
                        if let importError = error as? ImportListFromJSONError {
                            logging.debug("Import error: \(importError)")
                            throw UserListsActorError.importErrorForUser(user.representation)
                        }
                        throw error
                    }
            }
            .logError(.importListError, using: logging)
    }

}

// MARK: -

extension SetupItem.Boundaries {

    init(from boundaries: ImportListFromJSON.Boundaries) {
        self.worker = boundaries.worker
        self.imageStore = boundaries.imageStore
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static var importListError: LoggingMessageRoot<Error> {
        return .init({ error in
            LoggingMessage(label: "Import List", subject: error, level: .error)
        })
    }

    fileprivate static func importList(for user: User) -> LoggingMessageRoot<List> {
        return .init({ list in
            LoggingMessage(label: "Import List", subject: list, loggables: [user])
        })
    }

}

// MARK: Recording

extension RecordingEventRoot {

    fileprivate static func importList(for user: User) -> RecordingEventRoot<List> {
        return .init({ list in
            RecordingEvent(.IMPORTDATA, subject: list, attributes: ["user": user])
        })
    }

}
