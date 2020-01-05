import Foundation
import NIO

struct UserService {

    /// Repository for Users to be used by this service.
    let userRepository: UserRepository

    /// Initializes an User service.
    /// - Parameter userRepository: Repository for Users to be used by this service.
    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    /// Creates a user with the specified user values and sets the given identity.
    /// - Parameter userValues: Values for the user to create.
    /// - Parameter identity: Identity provided by the Identity Provider.
    /// - Parameter identityProvider: Identity Provider that provided the Identity.
    func createUser(
        from userValues: PartialValues<UserValues>,
        for identity: UserIdentity,
        of identityProvider: UserIdentityProvider
    ) throws -> EventLoopFuture<User> {
        return try UserValues(userValues)
            // validate values
            .validate(using: userRepository, existing: false)
            .flatMap { values in
                // update existing user with given user values
                let user = try User(from: values)
                // set user identity
                user.identity = identity
                user.identityProvider = identityProvider
                // set first login and last login
                user.firstLogin = Date()
                user.lastLogin = user.firstLogin
                return self.userRepository.save(user: user)
            }
    }

    /// Updates a user with the specified user values.
    /// - Parameter userValues: Values for the user to create.
    func updateUser(
        _ user: User,
        with userValues: PartialValues<UserValues>
    ) throws -> EventLoopFuture<User> {
        return try userValues.updating(user.values)
            // validate values of existing user updated with given user values
            .validate(using: userRepository, existing: true)
            .flatMap { values in
                // update existing user with given user values
                try user.update(from: values)
                // update last login
                user.lastLogin = Date()
                return self.userRepository.save(user: user)
            }
    }

}
