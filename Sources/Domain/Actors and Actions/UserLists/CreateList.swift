import Foundation
import NIO

// MARK: CreateList

public struct CreateList: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let values: ListValues
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

    internal let actor: () -> CreateListActor

    internal init(actor: @escaping @autoclosure () -> CreateListActor) {
        self.actor = actor
    }

    // MARK: Excecute

    internal func execute(with values: ListValues, for user: User, in boundaries: Boundaries) throws
        -> EventLoopFuture<(user: User, list: List)>
    {
        let actor = self.actor()
        let listRepository = actor.listRepository
        return try values.validate(for: user, using: listRepository)
            .flatMap { values in
                // create list
                let list = try List(for: user, from: values)
                return listRepository
                    .save(list: list)
                    .map { list in
                        return (user: user, list: list)
                    }
            }
            .catchFlatMap { error in
                if let valuesError = error as? ValuesError<ListValues> {
                    throw CreateListValidationError(user: user, error: valuesError)
                }
                throw error
            }
    }

}

// MARK: -

protocol CreateListActor {
    var listRepository: ListRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

protocol CreateListError: ActionError {
    var user: User { get }
}

struct CreateListValidationError: CreateListError {
    var user: User
    var error: ValuesError<ListValues>
}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: createList

    public func createList(
        _ specification: CreateList.Specification,
        _ boundaries: CreateList.Boundaries
    ) throws -> EventLoopFuture<CreateList.Result> {
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try CreateList(actor: self)
                    .execute(with: specification.values, for: user, in: boundaries)
                    .logMessage(.createList(for: user), for: { $0.list }, using: self.logging)
                    .recordEvent(
                        for: { $0.list }, "created for \(user)", using: self.recording
                    )
                    .map { user, list in
                        .init(user, list)
                    }
                    .catchMap { error in
                        if let createError = error as? CreateListValidationError {
                            self.logging.debug("List creation validation error: \(createError)")
                            let user = createError.user.representation
                            let error = createError.error
                            throw UserListsActorError.validationError(user, nil, error)
                        }
                        throw error
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func createList(for user: User) -> LoggingMessageRoot<List> {
        return .init({ list in
            LoggingMessage(label: "Create List", subject: list, loggables: [user])
        })
    }

}
