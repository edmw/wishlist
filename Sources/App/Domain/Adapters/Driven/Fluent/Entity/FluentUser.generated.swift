// sourcery:inline:FluentUser.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentUser

/// This generated type is based on the Domain‘s User model type and is used for
/// storing data into and retrieving data from a SQL database using Fluent.
///
/// The Domain builds relations between models using model identifiers (UserID, ListID, ...).
/// This will translate model identifiers to UUIDs and vice versa to handle relations using UUIDs.
public struct FluentUser: UserModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.uuid
    public static let name = "User"
    public static let migrationName = "User"

    public var uuid: UUID?
    public var id: UserID? { UserID(uuid: uuid) }
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

    /// Initializes a SQL layer's `FluentUser`. Usually not called directly.
    /// To create this object a getter `model` is provided on the Domain entity `User`.
    init(
        uuid: UUID?,
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
        self.uuid = uuid
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

    enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case identification
        case email
        case fullName
        case firstName
        case lastName
        case nickName
        case language
        case picture
        case confidant
        case settings
        case firstLogin
        case lastLogin
        case identity
        case identityProvider
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.uuid)
            builder.unique(on: \.uuid)
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
        return children(\FluentList.userKey)
    }

    // MARK: Equatable

    public static func == (lhs: FluentUser, rhs: FluentUser) -> Bool {
        guard lhs.uuid == rhs.uuid else {
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
            uuid: id?.uuid,
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

extension EventLoopFuture where Expectation == FluentUser {

    /// Maps this future‘s expectation from an SQL layer's `FluentUser`
    /// to the Domain entity `User`.
    func mapToEntity() -> EventLoopFuture<User> {
        return self.map { model in
            return User(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentUser? {

    /// Maps this future‘s expectation from an SQL layer's optional `FluentUser`
    /// to the optional Domain entity `User`.
    func mapToEntity() -> EventLoopFuture<User?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return User(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentUser] {

    /// Maps this future‘s expectation from an array of SQL layer's `FluentUser`s
    /// to an array of the Domain entities `User`s.
    func mapToEntities() -> EventLoopFuture<[User]> {
        return self.map { models in
            return models.map { model in User(from: model) }
        }
    }

}
// sourcery:end
