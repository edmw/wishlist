import Vapor
import Fluent
import FluentMySQL

/// Many-to-many relation between users and lists.
extension Favorite: ModifiablePivot {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

    typealias Left = User
    typealias Right = List

    static var leftIDKey: LeftIDKey = \.userID
    static var rightIDKey: RightIDKey = \.listID

}

// MARK: Migration

extension Favorite: Migration {

    static func prepare(on connection: Database.Connection) -> Future<Void> {
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
