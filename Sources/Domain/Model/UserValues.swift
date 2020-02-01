import Foundation
import NIO

// MARK: UserValues

/// Representation of a user with external properties only and with simple types.
/// Used for validation, importing and exporting.
public struct UserValues: Values, ValueValidatable {

    public var email: EmailSpecification
    public var fullName: String
    public var firstName: String
    public var lastName: String
    public var nickName: String?
    public var language: LanguageTag?
    public var picture: URL?

    public var confidant: Bool

    public var firstLogin: Date?
    public var lastLogin: Date?

    init(_ user: User) {
        self.email = user.email
        self.fullName = user.fullName
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.nickName = user.nickName
        self.language = user.language
        self.picture = user.picture
        self.confidant = user.confidant
        self.firstLogin = user.firstLogin
        self.lastLogin = user.lastLogin
    }

    init(_ values: PartialValues<UserValues>) throws {
        self.email = try values.value(for: \.email)
        self.fullName = try values.value(for: \.fullName)
        self.firstName = try values.value(for: \.firstName)
        self.lastName = try values.value(for: \.lastName)
        self.nickName = values[\.nickName]
        self.language = values[\.language]
        self.picture = values[\.picture]
        self.confidant = values[\.confidant] ?? false
        self.firstLogin = values[\.firstLogin]
        self.lastLogin = values[\.lastLogin]
    }

    // MARK: Validatable

    static func valueValidations() throws -> ValueValidations<UserValues> {
        var validations = ValueValidations(UserValues.self)
        validations.add(\.nickName, "nickName",
            (.nil || .empty ||
                (.count(3...User.maximumLengthOfNickName) &&
                    .characterSet(
                        .alphanumerics
                    )
                )
            )
        )
        return validations
    }

    /// Validates the given user data on conformance to the constraints of the model.
    /// - Values must validate (see Validatable)
    /// - Nickname must be unique if set
    /// - Parameter repository: the user repository
    /// - Parameter existing: set to true if the values of an existing user should be validated,
    ///     false by default
    func validate(using repository: UserRepository, existing: Bool = false)
        throws -> EventLoopFuture<UserValues>
    {
        do {
            try validateValues()
        }
        catch let error as ValueValidationErrors<UserValues> {
            return repository.future(
                error: ValuesError<UserValues>
                    .validationFailed(on: error.failedKeyPaths, reason: error.reason)
            )
        }
        // validate for user:
        if let nickName = nickName {
            // nick name must be unique
            return repository
                .count(nickName: nickName)
                .equals(
                    existing ? 1 : 0,
                    or: ValuesError<UserValues>.uniquenessViolated(for: \UserValues.nickName)
                )
                .transform(to: self)
        }
        else {
            return repository.future(self)
        }
    }

}

// MARK: -

extension User {

    convenience init(from data: UserValues) throws {
        self.init(
            email: data.email,
            fullName: data.fullName,
            firstName: data.firstName,
            lastName: data.lastName
        )
        self.nickName = data.nickName
        self.language = data.language
        self.picture = data.picture
        self.confidant = data.confidant
        self.firstLogin = data.firstLogin
        self.lastLogin = data.lastLogin
    }

    func update(from data: UserValues) throws {
        self.email = data.email
        self.fullName = data.fullName
        self.firstName = data.firstName
        self.lastName = data.lastName
        self.confidant = data.confidant
        self.nickName = data.nickName
        self.language = data.language
        self.picture = data.picture
        self.confidant = data.confidant
        self.firstLogin = data.firstLogin
        self.lastLogin = data.lastLogin
    }

}
