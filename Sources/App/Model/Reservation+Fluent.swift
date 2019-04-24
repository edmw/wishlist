import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension Reservation: Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

}

// MARK: Migration

extension Reservation: Migration {

    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.createdAt)
            builder.field(for: \.itemID)
            builder.field(for: \.holder)
            builder.reference(from: \.itemID, to: \Item.id, onDelete: .cascade)
        }
    }

}
