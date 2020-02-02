import Foundation

import Library

// MARK: Entity

/// User model
/// This type represents a user.
///
/// Relations:
/// - Childs: Lists
public final class User: UserModel,
    Entity,
    EntityDetachable,
    EntityReflectable,
    Loggable,
    Codable,
    Equatable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    static let maximumLengthOfNickName = 100

    public var id: UserID?

    public var identification: Identification

    public var email: EmailSpecification
    public var fullName: String
    public var firstName: String
    public var lastName: String
    public var nickName: String?
    public var language: LanguageTag?
    public var picture: URL?

    public var confidant: Bool

    public var settings: UserSettings

    public var firstLogin: Date?
    public var lastLogin: Date?

    /// authentication
    public var identity: UserIdentity?
    public var identityProvider: UserIdentityProvider?

    public var displayName: String {
        return nickName ?? firstName
    }

    public init<T: UserModel>(from other: T) {
        self.id = other.id
        self.identification = other.identification
        self.email = other.email
        self.fullName = other.fullName
        self.firstName = other.firstName
        self.lastName = other.lastName
        self.nickName = other.nickName
        self.language = other.language
        self.picture = other.picture
        self.confidant = other.confidant
        self.settings = other.settings
        self.firstLogin = other.firstLogin
        self.lastLogin = other.lastLogin
        self.identity = other.identity
        self.identityProvider = other.identityProvider
    }

    public init(
        id: UserID? = nil,
        email: EmailSpecification,
        fullName: String,
        firstName: String,
        lastName: String,
        nickName: String? = nil,
        language: LanguageTag? = nil,
        picture: URL? = nil
    ) {
        self.id = id

        self.identification = Identification()

        self.email = email
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
        self.nickName = nickName
        self.language = language
        self.picture = picture

        self.confidant = false

        self.settings = UserSettings()
    }

    var values: UserValues { .init(self) }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<User> = .build(
        .init(\User.id, label: "id"),
        .init(\User.identification, label: "identification"),
        .init(\User.email, label: "email"),
        .init(\User.fullName, label: "fullName"),
        .init(\User.firstName, label: "firstName"),
        .init(\User.lastName, label: "lastName"),
        .init(\User.nickName, label: "nickName"),
        .init(\User.language, label: "language"),
        .init(\User.picture, label: "picture"),
        .init(\User.confidant, label: "confidant"),
        .init(\User.settings, label: "settings"),
        .init(\User.firstLogin, label: "firstLogin"),
        .init(\User.lastLogin, label: "lastLogin"),
        .init(\User.identity, label: "identity"),
        .init(\User.identityProvider, label: "identityProvider")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "User[\(id ??? "???")][identification: \(identification)]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "User[\(id ??? "???")][identification: \(identification)]"
            + "(\(email), \(fullName))"
    }

}
