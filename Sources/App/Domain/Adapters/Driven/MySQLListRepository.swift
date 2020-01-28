import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: MySQLListRepository

/// Adapter for port `ListRepository` using MySQL database.
final class MySQLListRepository: ListRepository, MySQLModelRepository, AutoService {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Lists** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    // default sort order
    static let orderByNameKeyPath = \List.title
    static let orderByNameDirection = EntitySortingDirection.ascending
    static let orderByName = ListsSorting(orderByNameKeyPath, orderByNameDirection)
    static let orderByNameSql = MySQLDatabase.querySort(
        MySQLDatabase.queryField(.keyPath(orderByNameKeyPath)),
        orderByNameDirection.sqlDirection
    )

    func find(by id: ListID) -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return List.find(id.uuid, on: connection)
        }
    }

    func find(by id: ListID, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.id == id.uuid).first()
        }
    }

    func find(title: String) -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return List.query(on: connection).filter(\.title == title).first()
        }
    }

    func find(title: String, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.title == title).first()
        }
    }

    func findWithUser(by listid: ListID, for userid: UserID)
        -> EventLoopFuture<(List, User)?>
    {
        return db.withConnection { connection in
            return User.query(on: connection)
                .join(\List.userID, to: \User.id)
                .filter(\User.id == userid.uuid)
                .filter(\List.id == listid.uuid)
                .alsoDecode(List.self)
                .first()
                .map { row in row.map { ($0.1, $0.0) } }
        }
    }

    func all() -> EventLoopFuture<[List]> {
        return db.withConnection { connection in
            return List.query(on: connection).sort(\.title, .ascending).all()
        }
    }

    func all(for user: User) throws -> EventLoopFuture<[List]> {
        return try all(for: user, sort: MySQLListRepository.orderByName)
    }

    func all(
        for user: User,
        sort: ListsSorting
    ) throws -> EventLoopFuture<[List]> {
        return db.withConnection { connection in
            let orderBy = (try? sort.sqlOrderBy(on: List.self))
                                ???? MySQLListRepository.orderByNameSql
            return try user.lists
                .query(on: connection)
                .sort(orderBy)
                .sort(\.title, .ascending)
                .all()
        }
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return List.query(on: connection).filter(\.userID == userid.uuid).count()
        }
    }

    func count(title: String, for user: User) throws -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.title == title).count()
        }
    }

    func owner(of list: List) -> EventLoopFuture<User> {
        return db.withConnection { connection in
            return list.user.get(on: connection)
        }
    }

    func save(list: List) -> EventLoopFuture<List> {
        return db.withConnection { connection in
            if list.id == nil {
                // list create
                let limit = List.maximumNumberOfListsPerUser
                return List.query(on: connection)
                    .filter(\.userID == list.userID)
                    .count()
                    .max(limit, or: EntityError<List>.limitReached(maximum: limit))
                    .transform(to:
                        list.save(on: connection)
                    )
            }
            else {
                // list update
                return list.save(on: connection)
            }
        }
    }

    func delete(list: List, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            guard let userid = user.userID, userid == list.userID else {
                return connection.future(nil)
            }
            return list.delete(on: connection)
                .transform(to: list.detached())
        }
    }

    // Returns an available list title for a user based on the specified title
    // by appending an increasing counter to it.
    func available(title string: String, for user: User) throws -> EventLoopFuture<String?> {
        return try all(for: user)
            .map { lists in
                var title = string

                // build list of existing titles
                let titles = lists.map { list in list.title }

                if titles.contains(title) {
                    let prefix = String(title.prefix(List.maximumLengthOfTitle - 4))

                    // append increasing number to title until unique title is found
                    // (counts up to 99)
                    var counter = 0
                    repeat {
                        counter += 1
                        title = "\(prefix)_\(counter)"
                    } while titles.contains(title) && counter < 99

                    guard counter < 99 else {
                        // counter outrun (no unique name found)
                        return nil
                    }
                }

                return title
            }
    }

}
