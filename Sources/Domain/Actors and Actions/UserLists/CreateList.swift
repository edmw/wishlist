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

    internal func execute(
        for user: User,
        createWith values: ListValues,
        in boundaries: Boundaries
    ) throws
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
        let userRepository = self.userRepository
        let logging = self.logging
        let recording = self.recording
        return userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try CreateList(actor: self)
                    .execute(for: user, createWith: specification.values, in: boundaries)
                    .logMessage(.createList(for: user), for: { $0.list }, using: logging)
                    .recordEvent(.createList(for: user), for: { $0.list }, using: recording)
                    .map { user, list in
                        .init(user, list)
                    }
                    .catchMap { error in
                        if let createError = error as? CreateListValidationError {
                            logging.debug("List creation validation error: \(createError)")
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

// MARK: Recording

extension RecordingEventRoot {

    fileprivate static func createList(for user: User) -> RecordingEventRoot<List> {
        return .init({ list in
            RecordingEvent(.CREATEENTITY, subject: list, attributes: ["user": user])
        })
    }

}
