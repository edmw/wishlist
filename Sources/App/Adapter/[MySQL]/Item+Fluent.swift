import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension Item: Fluent.Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

    /// Parent relation: List
    var list: Parent<Item, List> {
        return parent(\.listID)
    }

}

// MARK: Migration

extension Item: Migration {

    static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.title, type: .varchar(255))
            builder.field(for: \.text, type: .longtext)
            builder.field(for: \.preference, type: .tinyint)
            builder.field(for: \.url)
            builder.field(for: \.imageURL)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.localImageURL)
            builder.field(for: \.listID)
            builder.reference(from: \.listID, to: \List.id, onDelete: .cascade)
        }
    }

}

// MARK: -

/// This extension conforms the item preference to be usable with Fluent MySQL.
extension Item.Preference: MySQLEnumType {

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    /// I don't know what this does and how this works.
    static func reflectDecoded() throws -> (Item.Preference, Item.Preference) {
        return (.low, .high)
    }

}

/// This extension conforms the items sorting to be usable with Fluent MySQL.
extension ItemsSorting: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of VARCHAR(255).
    static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    /// I don't know what this does and how this works.
    static func reflectDecoded() throws -> (ItemsSorting, ItemsSorting) {
        return (.ascending(propertyName: "id"), .descending(propertyName: "id"))
    }

}
