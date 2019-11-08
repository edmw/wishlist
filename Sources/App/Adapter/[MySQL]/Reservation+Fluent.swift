import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension Reservation: Fluent.Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

    /// Parent relation: Item
    var item: Parent<Reservation, Item> {
        return parent(\.itemID)
    }

}

// MARK: Migration

extension Reservation: Migration {

    static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.createdAt)
            builder.field(for: \.itemID)
            builder.field(for: \.holder)
            builder.reference(from: \.itemID, to: \Item.id, onDelete: .cascade)
        }
    }

}
