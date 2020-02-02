// sourcery:inline:FluentInvitation.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentInvitation

/// This generated type is based on the Domain‘s Invitation model type and is used for
/// storing data into and retrieving data from a SQL database using Fluent.
///
/// The Domain builds relations between models using model identifiers (UserID, ListID, ...).
/// This will translate model identifiers to UUIDs and vice versa to handle relations using UUIDs.
public struct FluentInvitation: InvitationModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.uuid
    public static let name = "Invitation"
    public static let migrationName = "Invitation"

    public var uuid: UUID?
    public var id: InvitationID? { InvitationID(uuid: uuid) }
    public var code: InvitationCode
    public var status: Invitation.Status
    public var email: EmailSpecification
    public var sentAt: Date?
    public var createdAt: Date
    public var userKey: UUID
    public var userID: UserID { UserID(uuid: userKey) }
    public var inviteeKey: UUID?
    public var inviteeID: UserID? { UserID(uuid: inviteeKey) }

    /// Initializes a SQL layer's `FluentInvitation`. Usually not called directly.
    /// To create this object a getter `model` is provided on the Domain entity `Invitation`.
    init(
        uuid: UUID?,
        code: InvitationCode,
        status: Invitation.Status,
        email: EmailSpecification,
        sentAt: Date?,
        createdAt: Date,
        userKey: UUID,
        inviteeKey: UUID?
    ) {
        self.uuid = uuid
        self.code = code
        self.status = status
        self.email = email
        self.sentAt = sentAt
        self.createdAt = createdAt
        self.userKey = userKey
        self.inviteeKey = inviteeKey
    }

    enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case code
        case status
        case email
        case sentAt
        case createdAt
        case userKey = "userID"
        case inviteeKey = "inviteeID"
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.uuid)
            builder.field(for: \.code)
            builder.unique(on: \.code)
            builder.field(for: \.status)
            builder.field(for: \.email)
            builder.field(for: \.sentAt)
            builder.field(for: \.createdAt)
            builder.field(for: \.userKey)
            builder.field(for: \.inviteeKey)
            builder.reference(from: \.userKey, to: \FluentUser.id)
        }
    }

    // MARK: Relations

    var user: Parent<FluentInvitation, FluentUser> {
        return parent(\FluentInvitation.userKey)
    }

    func requireUser(on container: Container) throws -> EventLoopFuture<User> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.user.get(on: connection).mapToEntity()
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentInvitation, rhs: FluentInvitation) -> Bool {
        guard lhs.uuid == rhs.uuid else {
            return false
        }
        guard lhs.code == rhs.code else {
            return false
        }
        guard lhs.status == rhs.status else {
            return false
        }
        guard lhs.email == rhs.email else {
            return false
        }
        guard lhs.sentAt == rhs.sentAt else {
            return false
        }
        guard lhs.createdAt == rhs.createdAt else {
            return false
        }
        guard lhs.userKey == rhs.userKey else {
            return false
        }
        guard lhs.inviteeKey == rhs.inviteeKey else {
            return false
        }
        return true
    }

}

// MARK: - Invitation

extension Invitation {

    var model: FluentInvitation {
        return .init(
            uuid: id?.uuid,
            code: code,
            status: status,
            email: email,
            sentAt: sentAt,
            createdAt: createdAt,
            userKey: userID.uuid,
            inviteeKey: inviteeID?.uuid
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentInvitation {

    /// Maps this future‘s expectation from an SQL layer's `FluentInvitation`
    /// to the Domain entity `Invitation`.
    func mapToEntity() -> EventLoopFuture<Invitation> {
        return self.map { model in
            return Invitation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentInvitation? {

    /// Maps this future‘s expectation from an SQL layer's optional `FluentInvitation`
    /// to the optional Domain entity `Invitation`.
    func mapToEntity() -> EventLoopFuture<Invitation?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Invitation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentInvitation] {

    /// Maps this future‘s expectation from an array of SQL layer's `FluentInvitation`s
    /// to an array of the Domain entities `Invitation`s.
    func mapToEntities() -> EventLoopFuture<[Invitation]> {
        return self.map { models in
            return models.map { model in Invitation(from: model) }
        }
    }

}
// sourcery:end
