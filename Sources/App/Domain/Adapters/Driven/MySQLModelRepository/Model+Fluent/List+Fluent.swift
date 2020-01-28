import Domain

import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension List: Fluent.Model {

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id

    /// Parent relation: User
    var user: Parent<List, User> {
        return parent(\List.userID)
    }
    /// Childs relation: Items
    var items: Children<List, Item> {
        return children(\Item.listID)
    }

}

// MARK: Migration

extension List: Migration {

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.title, type: .varchar(255))
            builder.field(for: \.visibility, type: .tinyint)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.options)
            builder.field(for: \.itemsSorting, type: ItemsSorting.mysqlDataType)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
        }
    }

}

/// This extension conforms the options to be usable with Fluent MySQL.
extension List.Options: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of SMALLINT.
    public static var mysqlDataType: MySQLDataType {
        return .smallint()
    }

    /// Simply store the raw value into the database.
    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    /// Simply read a raw value from the database.
    public static func convertFromMySQLData(_ data: MySQLData) throws -> List.Options {
        return try self.init(rawValue: .convertFromMySQLData(data))
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    public static func reflectDecoded() throws -> (List.Options, List.Options) {
        return ([], [.maskReservations])
    }

}
