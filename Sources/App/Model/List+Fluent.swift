import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension List: Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

    /// Parent relation: User
    var user: Parent<List, User> {
        return parent(\.userID)
    }
    /// Childs relation: Items
    var items: Children<List, Item> {
        return children(\.listID)
    }

}

// MARK: Migration

extension List: Migration {

    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.name, type: .varchar(255))
            builder.field(for: \.visibility, type: .tinyint)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.itemsSorting, type: ItemsSorting.mysqlDataType)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
        }
    }

}
