import Domain

import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension Invitation: Fluent.Model {

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id

    /// Parent relation: User
    var user: Parent<Invitation, User> {
        return parent(\Invitation.userID)
    }

    func requireUser(on container: Container) throws -> EventLoopFuture<User> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.user.get(on: connection)
        }
    }

}

// MARK: Migration

extension Invitation: Migration {

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.code, type: InvitationCode.mysqlDataType)
            builder.field(for: \.status, type: .tinyint)
            builder.field(for: \.email)
            builder.field(for: \.sentAt)
            builder.field(for: \.createdAt)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.invitee)
            builder.unique(on: \.code)
        }
    }

}

extension Invitation.Status: MySQLEnumType {

    public static func reflectDecoded() throws -> (Invitation.Status, Invitation.Status) {
        return (.open, .revoked)
    }

}
