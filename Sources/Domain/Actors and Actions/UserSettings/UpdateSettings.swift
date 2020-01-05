import Foundation
import NIO

// MARK: UpdateSettings

public struct UpdateSettings: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public static func boundaries(worker: EventLoop) -> Self {
            return Self(worker: worker)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public let settingsValues: PartialValues<UserSettings>
        public static func specification(
            userBy userid: UserID,
            from settingsValues: PartialValues<UserSettings>
        ) -> Self {
            return Self(userID: userid, settingsValues: settingsValues)
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        internal init(_ user: User) {
            self.user = user.representation
        }
    }

    // MARK: -

    internal let actor: () -> UpdateSettingsActor

    internal init(actor: @escaping @autoclosure () -> UpdateSettingsActor) {
        self.actor = actor
    }

    // MARK: Execute

    /// Saves a user with settings updated from the given partial values.
    /// Validates the values, checks the constraints required for an updated user and updates an
    /// existing user.
    ///
    /// Throws `ValuesError`s for invalid values or violated constraints.
    internal func execute(
        on user: User,
        with values: PartialValues<UserSettings>,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<User>
    {
        let actor = self.actor()
        let userRepository = actor.userRepository
        return try values.updating(user.settings)
            .validate(using: userRepository)
            .flatMap { values in
                // update user
                user.settings = values
                return userRepository
                    .save(user: user)
            }
    }

}

// MARK: - Actor

extension DomainUserSettingsActor {

    // MARK: updateSettings

    public func updateSettings(
        _ specification: UpdateSettings.Specification,
        _ boundaries: UpdateSettings.Boundaries
    ) throws -> EventLoopFuture<UpdateSettings.Result> {
        let logging = self.logging
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                let settingsvalues = specification.settingsValues
                return try UpdateSettings(actor: self)
                    .execute(on: user, with: settingsvalues, in: boundaries)
                    .logMessage("settings updated", using: logging)
                    .map { user in
                        .init(user)
                    }
                    .catchMap { error in
                        if let valuesError = error as? ValuesError<UserSettings> {
                            logging.debug("Settings updating validation error: \(valuesError)")
                            throw UserSettingsActorError
                                .validationError(user.representation, valuesError)
                        }
                        throw error
                    }
            }
    }

}

// MARK: -

internal protocol UpdateSettingsActor {
    var userRepository: UserRepository { get }
    var logging: MessageLoggingProvider { get }
    var recording: EventRecordingProvider { get }
}
