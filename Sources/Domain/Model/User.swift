import Library

import Foundation

// MARK: Entity

/// User model
/// This type represents a user.
///
/// Relations:
/// - Childs: Lists
public final class User: Entity,
    EntityDetachable,
    EntityReflectable,
    Codable,
    Equatable,
    Loggable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    static let maximumLengthOfNickName = 100

    public var id: UUID? {
        didSet { userID = UserID(uuid: id) }
    }
    public lazy var userID = UserID(uuid: id)

    public var identification: Identification

    public var email: EmailSpecification
    public var fullName: String
    public var firstName: String
    public var lastName: String
    public var nickName: String?
    public var language: String?
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

    init(
        id: UserID? = nil,
        email: EmailSpecification,
        fullName: String,
        firstName: String,
        lastName: String
    ) {
        self.id = id?.uuid

        self.identification = Identification()

        self.email = email
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName

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
        return "User[\(id ??? "???"):\(userID ??? "???")][identification: \(identification)]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "User[\(id ??? "???"):\(userID ??? "???")][identification: \(identification)]"
            + "(\(email), \(fullName))"
    }

}
