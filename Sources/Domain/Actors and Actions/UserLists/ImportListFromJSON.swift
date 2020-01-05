import Foundation
import NIO

// MARK: ImportListFromJSON

public struct ImportListFromJSON: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public let imageStore: ImageStoreProvider
        public static func boundaries(worker: EventLoop, imageStore: ImageStoreProvider) -> Self {
            return Self(worker: worker, imageStore: imageStore)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public let json: String
        public static func specification(userBy userid: UserID, json: String) -> Self {
            return Self(userID: userid, json: json)
        }
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

    internal let actor: () -> ImportListFromJSONActor & CreateItemActor

    internal init(actor: @escaping @autoclosure () -> ImportListFromJSONActor & CreateItemActor) {
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
            .unwrap(or: ImportListFromJSONNoListNameError(user: user))
            .flatMap { title in
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

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: importList

    public func importList(
        _ specification: ImportListFromJSON.Specification,
        _ boundaries: ImportListFromJSON.Boundaries
    ) throws -> EventLoopFuture<ImportListFromJSON.Result> {
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try ImportListFromJSON(actor: self)
                    .execute(with: specification.json, for: user, in: boundaries)
                    .recordEvent("imported for \(user)", using: self.recording)
                    .logMessage("imported for \(user)", using: self.logging)
                    .map { list in
                        .init(user, list)
                    }
                    .catchMap { error in
                        if let importError = error as? ImportListFromJSONError {
                            self.logging.debug("Import error: \(importError)")
                            throw UserListsActorError.importErrorForUser(user.representation)
                        }
                        throw error
                    }
            }
    }

}

// MARK: -

protocol ImportListFromJSONActor {
    var listRepository: ListRepository { get }
    var itemRepository: ItemRepository { get }
    var logging: MessageLoggingProvider { get }
}

protocol ImportListFromJSONError: ActionError {
}

struct ImportListFromJSONNoListNameError: ImportListFromJSONError {
    var user: User
}

struct ImportListFromJSONValidationError: ImportListFromJSONError {
    var error: AnyEntityError
}

// MARK: -

extension CreateItem.Boundaries {

    init(from boundaries: ImportListFromJSON.Boundaries) {
        self.worker = boundaries.worker
        self.imageStore = boundaries.imageStore
    }

}
