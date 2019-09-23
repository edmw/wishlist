import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension User: Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

    /// Childs relation: Lists
    var lists: Children<User, List> {
        return children(\.userID)
    }

}

// MARK: Migration

extension User: Migration {

    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.identification)
            builder.field(for: \.email, type: .varchar(255))
            builder.field(for: \.fullName)
            builder.field(for: \.firstName)
            builder.field(for: \.lastName)
            builder.field(for: \.nickName)
            builder.field(for: \.language, type: .varchar(10))
            builder.field(for: \.picture)
            builder.field(for: \.confidant)
            builder.field(for: \.settings)
            builder.field(for: \.firstLogin)
            builder.field(for: \.lastLogin)
            builder.field(for: \.subjectId)
            builder.unique(on: \.identification)
        }
    }

}
