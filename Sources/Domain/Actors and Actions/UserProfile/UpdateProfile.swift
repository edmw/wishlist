import Foundation
import NIO

// MARK: UpdateProfile

public struct UpdateProfile: Action {

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
        public let userValues: PartialValues<UserValues>
        public static func specification(
            userBy userid: UserID,
            from userValues: PartialValues<UserValues>
        ) -> Self {
            return Self(userID: userid, userValues: userValues)
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

    internal let actor: () -> UpdateProfileActor

    internal init(actor: @escaping @autoclosure () -> UpdateProfileActor) {
        self.actor = actor
    }

    // MARK: Execute

    /// Saves a user updated from the given partial values.
    /// Validates the values, checks the constraints required for an updated user and updates an
    /// existing user.
    ///
    /// Throws `ValuesError`s for invalid values or violated constraints.
    internal func execute(
        on user: User,
        with values: PartialValues<UserValues>,
        in boundaries: Boundaries
    ) throws
        -> EventLoopFuture<User>
    {
        let actor = self.actor()
        let userRepository = actor.userRepository
        return try values.updating(user.values)
            .validate(using: userRepository)
            .flatMap { values in
                // update user
                try user.update(from: values)
                return userRepository
                    .save(user: user)
            }
    }

}

// MARK: - Actor

extension DomainUserProfileActor {

    // MARK: updateProfile

    public func updateProfile(
        _ specification: UpdateProfile.Specification,
        _ boundaries: UpdateProfile.Boundaries
    ) throws -> EventLoopFuture<UpdateProfile.Result> {
        let logging = self.logging
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                let uservalues = specification.userValues
                return try UpdateProfile(actor: self)
                    .execute(on: user, with: uservalues, in: boundaries)
                    .logMessage("user updated", using: logging)
                    .map { user in
                        .init(user)
                    }
                    .catchMap { error in
                        if let valuesError = error as? ValuesError<UserValues> {
                            logging.debug("User updating validation error: \(valuesError)")
                            throw UserProfileActorError
                                .validationError(user.representation, valuesError)
                        }
                        throw error
                    }
            }
    }

}

// MARK: -

protocol UpdateProfileActor {
    var userRepository: UserRepository { get }
    var logging: MessageLoggingProvider { get }
    var recording: EventRecordingProvider { get }
}
