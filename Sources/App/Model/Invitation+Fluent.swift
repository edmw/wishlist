import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension Invitation: Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

}

// MARK: Migration

extension Invitation: Migration {

    static func prepare(on connection: Database.Connection) -> Future<Void> {
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

    static func reflectDecoded() throws -> (Invitation.Status, Invitation.Status) {
        return (.open, .revoked)
    }

}
