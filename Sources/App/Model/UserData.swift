import Vapor

/// Representation of a user with external properties only
/// and with simple types.
/// Used for validation, importing and exporting.
struct UserData: Content, Validatable, Reflectable {

    var email: String
    var name: String

    var firstName: String
    var lastName: String
    var nickName: String?
    var language: String?
    var picture: URL?

    var confidant: Bool

    var firstLogin: Date?
    var lastLogin: Date?

    init(_ user: User) {
        self.email = user.email
        self.name = user.name
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.nickName = user.nickName
        self.language = user.language
        self.picture = user.picture
        self.confidant = user.confidant
        self.firstLogin = user.firstLogin
        self.lastLogin = user.lastLogin
    }

    // MARK: Validatable {

    static func validations() throws -> Validations<UserData> {
        var validations = Validations(UserData.self)
        try validations.add(\.nickName,
            (.nil || .empty ||
                (.count(4...User.maximumLengthOfNickName) &&
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
    /// - Nickname must be unique
    func validate(
        using repository: UserRepository
    ) throws -> Future<UserData> {
        do {
            try validate()
        }
        catch let error as ValidationError {
            var properties = [PartialKeyPath<User>]()
            // WORKAROUND: See https://github.com/vapor/validation/issues/26
            // This is a hack which parses the textual reason for an validation error.
            let reason = error.reason
            if reason.contains("'nickName'") {
                properties.append(\User.nickName)
            }
            throw EntityError.validationFailed(on: properties, reason: reason)
        }
        // validate for user:
        if let nickName = nickName {
            // nick name must be unique
            return repository
                .find(nickName: nickName)
                .nil(or: EntityError<User>.uniquenessViolated(for: \User.nickName))
                .transform(to: self)
        }
        else {
            return repository.future(self)
        }
    }

}

// MARK: -

extension User {

    convenience init(from data: UserData) throws {
        self.init(
            email: data.email,
            name: data.name,
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

    func update(from data: UserData) throws {
        self.email = data.email
        self.name = data.name
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
