// sourcery:inline:FluentUser.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentUser

/// This generated type is based on the Domain‘s FluentUser model type and is used for
/// storing data to and retrieving data from a SQL database using Fluent.
public struct FluentUser: UserModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id
    public static let name = "User"
    public static let migrationName = "User"

    public var id: UUID?
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
    public var identity: UserIdentity?
    public var identityProvider: UserIdentityProvider?

    init(
        id: UUID?,
        identification: Identification,
        email: EmailSpecification,
        fullName: String,
        firstName: String,
        lastName: String,
        nickName: String?,
        language: LanguageTag?,
        picture: URL?,
        confidant: Bool,
        settings: UserSettings,
        firstLogin: Date?,
        lastLogin: Date?,
        identity: UserIdentity?,
        identityProvider: UserIdentityProvider?
    ) {
        self.id = id
        self.identification = identification
        self.email = email
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
        self.nickName = nickName
        self.language = language
        self.picture = picture
        self.confidant = confidant
        self.settings = settings
        self.firstLogin = firstLogin
        self.lastLogin = lastLogin
        self.identity = identity
        self.identityProvider = identityProvider
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.unique(on: \.id)
            builder.field(for: \.identification)
            builder.unique(on: \.identification)
            builder.field(for: \.email)
            builder.field(for: \.fullName)
            builder.field(for: \.firstName)
            builder.field(for: \.lastName)
            builder.field(for: \.nickName)
            builder.field(for: \.language)
            builder.field(for: \.picture)
            builder.field(for: \.confidant)
            builder.field(for: \.settings)
            builder.field(for: \.firstLogin)
            builder.field(for: \.lastLogin)
            builder.field(for: \.identity)
            builder.field(for: \.identityProvider)
        }
    }

    // MARK: Relations

    var lists: Children<FluentUser, FluentList> {
        return children(\FluentList.userID)
    }

    // MARK: Equatable

    public static func == (lhs: FluentUser, rhs: FluentUser) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        guard lhs.identification == rhs.identification else {
            return false
        }
        guard lhs.email == rhs.email else {
            return false
        }
        guard lhs.fullName == rhs.fullName else {
            return false
        }
        guard lhs.firstName == rhs.firstName else {
            return false
        }
        guard lhs.lastName == rhs.lastName else {
            return false
        }
        guard lhs.nickName == rhs.nickName else {
            return false
        }
        guard lhs.language == rhs.language else {
            return false
        }
        guard lhs.picture == rhs.picture else {
            return false
        }
        guard lhs.confidant == rhs.confidant else {
            return false
        }
        guard lhs.settings == rhs.settings else {
            return false
        }
        guard lhs.firstLogin == rhs.firstLogin else {
            return false
        }
        guard lhs.lastLogin == rhs.lastLogin else {
            return false
        }
        guard lhs.identity == rhs.identity else {
            return false
        }
        guard lhs.identityProvider == rhs.identityProvider else {
            return false
        }
        return true
    }

}

// MARK: - User

extension User {

    var model: FluentUser {
        return .init(
            id: id,
            identification: identification,
            email: email,
            fullName: fullName,
            firstName: firstName,
            lastName: lastName,
            nickName: nickName,
            language: language,
            picture: picture,
            confidant: confidant,
            settings: settings,
            firstLogin: firstLogin,
            lastLogin: lastLogin,
            identity: identity,
            identityProvider: identityProvider
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentUser? {

    func mapToEntity() -> EventLoopFuture<User?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return User(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentUser {

    func mapToEntity() -> EventLoopFuture<User> {
        return self.map { model in
            return User(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentUser] {

    func mapToEntities() -> EventLoopFuture<[User]> {
        return self.map { models in
            return models.map { model in User(from: model) }
        }
    }

}
// sourcery:end
