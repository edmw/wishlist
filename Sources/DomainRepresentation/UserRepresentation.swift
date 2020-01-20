import Library

import Foundation

// MARK: UserRepresentation

public struct UserRepresentation: Encodable,
    Equatable,
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

    internal init(_ user: User) {
        self.id = user.userID

        self.nickName = user.nickName
        self.displayName = user.displayName
        self.fullName = user.fullName
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = String(user.email)
        self.language = user.language
        self.confidant = user.confidant
        self.firstLogin = user.firstLogin
        self.lastLogin = user.lastLogin

        self.settings = user.settings
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

extension User {

    /// Returns a representation for this model.
    var representation: UserRepresentation {
        return .init(self)
    }

}