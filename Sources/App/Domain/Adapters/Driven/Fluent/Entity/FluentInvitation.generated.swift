// sourcery:inline:FluentInvitation.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentInvitation

/// This generated type is based on the Domain‘s FluentInvitation model type and is used for
/// storing data to and retrieving data from a SQL database using Fluent.
public struct FluentInvitation: InvitationModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id
    public static let name = "Invitation"
    public static let migrationName = "Invitation"

    public var id: UUID?
    public var code: InvitationCode
    public var status: Invitation.Status
    public var email: EmailSpecification
    public var sentAt: Date?
    public var createdAt: Date
    public var userID: UUID
    public var invitee: UUID?

    init(
        id: UUID?,
        code: InvitationCode,
        status: Invitation.Status,
        email: EmailSpecification,
        sentAt: Date?,
        createdAt: Date,
        userID: UUID,
        invitee: UUID?
    ) {
        self.id = id
        self.code = code
        self.status = status
        self.email = email
        self.sentAt = sentAt
        self.createdAt = createdAt
        self.userID = userID
        self.invitee = invitee
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.code)
            builder.unique(on: \.code)
            builder.field(for: \.status)
            builder.field(for: \.email)
            builder.field(for: \.sentAt)
            builder.field(for: \.createdAt)
            builder.field(for: \.userID)
            builder.field(for: \.invitee)
            builder.reference(from: \.userID, to: \FluentUser.id)
        }
    }

    // MARK: Relations

    var user: Parent<FluentInvitation, FluentUser> {
        return parent(\FluentInvitation.userID)
    }

    func requireUser(on container: Container) throws -> EventLoopFuture<User> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.user.get(on: connection).mapToEntity()
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentInvitation, rhs: FluentInvitation) -> Bool {
        guard lhs.id == rhs.id else {
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
        guard lhs.userID == rhs.userID else {
            return false
        }
        guard lhs.invitee == rhs.invitee else {
            return false
        }
        return true
    }

}

// MARK: - Invitation

extension Invitation {

    var model: FluentInvitation {
        return .init(
            id: id,
            code: code,
            status: status,
            email: email,
            sentAt: sentAt,
            createdAt: createdAt,
            userID: userID,
            invitee: invitee
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentInvitation? {

    func mapToEntity() -> EventLoopFuture<Invitation?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Invitation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentInvitation {

    func mapToEntity() -> EventLoopFuture<Invitation> {
        return self.map { model in
            return Invitation(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentInvitation] {

    func mapToEntities() -> EventLoopFuture<[Invitation]> {
        return self.map { models in
            return models.map { model in Invitation(from: model) }
        }
    }

}
// sourcery:end
