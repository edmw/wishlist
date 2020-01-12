import Foundation
import NIO

// MARK: UpdateList

public struct UpdateList: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
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

    internal let actor: () -> UpdateListActor

    internal init(actor: @escaping @autoclosure () -> UpdateListActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        on list: List,
        with values: ListValues,
        for user: User,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<(user: User, list: List)>
    {
        let actor = self.actor()
        let listRepository = actor.listRepository
        return try values.validate(for: user, this: list, using: listRepository)
            .flatMap { values in
                // update list
                try list.update(for: user, from: values)
                list.modifiedAt = Date()
                return listRepository
                    .save(list: list)
                    .map { list in
                        return (user: user, list: list)
                    }
            }
            .catchFlatMap { error in
                if let valuesError = error as? ValuesError<ListValues> {
                    throw UpdateListValidationError(user: user, list: list, error: valuesError)
                }
                throw error
            }
    }

}

// MARK: -

protocol UpdateListActor {
    var listRepository: ListRepository { get }
    var logging: MessageLoggingProvider { get }
    var recording: EventRecordingProvider { get }
}

protocol UpdateListError: ActionError {
    var user: User { get }
    var list: List { get }
}

struct UpdateListInvalidOwnerError: UpdateListError {
    var user: User
    var list: List
}

struct UpdateListValidationError: UpdateListError {
    var user: User
    var list: List
    var error: ValuesError<ListValues>
}

// MARK: - Actor

extension DomainUserListsActor {

    // MARK: updateList

    public func updateList(
        _ specification: UpdateList.Specification,
        _ boundaries: UpdateList.Boundaries
    ) throws -> EventLoopFuture<UpdateList.Result> {
        return self.userRepository
            .find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                return try self.listRepository
                    .find(by: specification.listID, for: user)
                    .unwrap(or: UserListsActorError.invalidList)
                    .flatMap { list in
                        let listvalues = specification.values
                        return try UpdateList(actor: self)
                            .execute(on: list, with: listvalues, for: user, in: boundaries)
                            .logMessage(.updateList, using: self.logging)
                            .map { user, list in
                                .init(user, list)
                            }
                            .catchMap { error in
                                if let updateError = error as? UpdateListValidationError {
                                    self.logging.debug(
                                        "List updating validation error: \(updateError)"
                                    )
                                    throw UserListsActorError.validationError(
                                        updateError.user.representation,
                                        updateError.list.representation,
                                        updateError.error
                                    )
                                }
                                throw error
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    static var updateList: Self {
        return Self({ subject in
            LoggingMessage(label: "Update List", subject: subject, attributes: [])
        })
    }

}
