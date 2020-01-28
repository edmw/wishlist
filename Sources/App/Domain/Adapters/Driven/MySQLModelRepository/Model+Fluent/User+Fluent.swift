import Domain

import Vapor
import Fluent
import FluentMySQL

/// Configure database mapping
extension User: Fluent.Model {

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id

    /// Childs relation: Lists
    var lists: Children<User, List> {
        return children(\List.userID)
    }

}

// MARK: Migration

extension User: Migration {

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.identification)
            builder.unique(on: \.identification)
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
            builder.field(for: \.identity)
            builder.field(for: \.identityProvider)
        }
    }

}
