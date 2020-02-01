import Foundation

import Library

// MARK: UserRepresentation

public struct UserRepresentation: Encodable, Equatable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    public let id: UserID?

    public let nickName: String?
    public let displayName: String
    public let fullName: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let language: String?
    public let confidant: Bool
    public let firstLogin: Date?
    public let lastLogin: Date?

    public let settings: UserSettings

    init(
        id: UserID?,
        nickName: String?,
        displayName: String,
        fullName: String,
        firstName: String,
        lastName: String,
        email: String,
        language: String?,
        confidant: Bool,
        firstLogin: Date?,
        lastLogin: Date?,
        settings: UserSettings
    ) {
        self.id = id
        self.nickName = nickName
        self.displayName = displayName
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.language = language
        self.confidant = confidant
        self.firstLogin = firstLogin
        self.lastLogin = lastLogin
        self.settings = settings
    }

    init(_ user: User) {
        self.init(
            id: user.userID,
            nickName: user.nickName,
            displayName: user.displayName,
            fullName: user.fullName,
            firstName: user.firstName,
            lastName: user.lastName,
            email: String(user.email),
            language: String(user.language ?? "�"),
            confidant: user.confidant,
            firstLogin: user.firstLogin,
            lastLogin: user.lastLogin,
            settings: user.settings
        )
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return "UserRepresentation[\(id ??? "???")]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "UserRepresentation[\(id ??? "???")]"
            + "(\(email), \(fullName))"
    }

}
