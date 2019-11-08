import Vapor
import Fluent
import FluentMySQL
import Authentication

// MARK: Entity

/// User model
/// This type represents an signed in user.
///
/// Relations:
/// - Childs: Lists
final class User: Entity,
    EntityReflectable,
    Content,
    SessionAuthenticatable,
    CustomStringConvertible
{

    static let maximumLengthOfNickName = 100

    var id: UUID?

    var identification: Identification

    var email: String
    var fullName: String
    var firstName: String
    var lastName: String
    var nickName: String?
    var language: String?
    var picture: URL?

    var confidant: Bool

    var settings: UserSettings

    var firstLogin: Date?
    var lastLogin: Date?

    /// authentication
    var subjectId: String?

    var displayName: String {
        return nickName ?? firstName
    }

    init(
        id: UUID? = nil,
        email: String,
        fullName: String,
        firstName: String,
        lastName: String
    ) {
        self.id = id

        self.identification = Identification()

        self.email = email
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName

        self.confidant = false

        self.settings = UserSettings()
    }

    // MARK: EntityReflectable

    static var properties: [PartialKeyPath<User>] = [
        \User.id,
        \User.identification,
        \User.email,
        \User.fullName,
        \User.firstName,
        \User.lastName,
        \User.nickName,
        \User.language,
        \User.picture,
        \User.confidant,
        \User.settings,
        \User.firstLogin,
        \User.lastLogin,
        \User.subjectId
    ]

    static func propertyName(forKey keyPath: PartialKeyPath<User>) -> String? {
        switch keyPath {
        case \User.id: return "id"
        case \User.identification: return "identification"
        case \User.email: return "email"
        case \User.fullName: return "fullName"
        case \User.firstName: return "firstName"
        case \User.lastName: return "lastName"
        case \User.nickName: return "nickName"
        case \User.language: return "language"
        case \User.picture: return "picture"
        case \User.confidant: return "confidant"
        case \User.settings: return "settings"
        case \User.firstLogin: return "firstLogin"
        case \User.lastLogin: return "lastLogin"
        case \User.subjectId: return "subjectId"
        default: return nil
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "User[\(id ??? "???")][\(identification)](\(email), \(fullName))"
    }

}
