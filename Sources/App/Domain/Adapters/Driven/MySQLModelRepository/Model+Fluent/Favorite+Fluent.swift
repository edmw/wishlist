import Domain

import Vapor
import Fluent
import FluentMySQL

/// Many-to-many relation between users and lists.
extension Favorite: ModifiablePivot {

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id

    public typealias Left = User
    public typealias Right = List

    public static var leftIDKey: LeftIDKey = \Favorite.userID
    public static var rightIDKey: RightIDKey = \Favorite.listID

}

// MARK: Migration

extension Favorite: Migration {

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.userID)
            builder.field(for: \.listID)
        }
    }

}

// MARK: -

extension User {

    // this user's favorite lists
    var favorites: Siblings<User, List, Favorite> {
        return siblings()
    }

}

// MARK: -

extension List {

    // all users that favorite this list
    var planets: Siblings<List, User, Favorite> {
        return siblings()
    }

}
