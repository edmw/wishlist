import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentListRepository

/// Adapter for port `ListRepository` using MySQL database.
final class FluentListRepository: ListRepository, FluentRepository {
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
            return FluentList.find(id.uuid, on: connection)
                .mapToEntity()
        }
    }

    func find(by id: ListID, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return try user.model.lists.query(on: connection)
                .filter(\.id == id.uuid)
                .first()
                .mapToEntity()
        }
    }

    func find(title: Title) -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return FluentList.query(on: connection)
                .filter(\.title == title)
                .first()
                .mapToEntity()
        }
    }

    func find(title: Title, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return try user.model.lists.query(on: connection)
                .filter(\.title == title)
                .first()
                .mapToEntity()
        }
    }

    func findWithUser(by listid: ListID, for userid: UserID)
        -> EventLoopFuture<(List, User)?>
    {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .join(\FluentList.userID, to: \FluentUser.id)
                .filter(\FluentUser.id == userid.uuid)
                .filter(\FluentList.id == listid.uuid)
                .alsoDecode(FluentList.self)
                .first()
                .mapToEntities()
        }
    }

    func all() -> EventLoopFuture<[List]> {
        return db.withConnection { connection in
            return FluentList.query(on: connection)
                .sort(\.title, .ascending)
                .all()
                .mapToEntities()
        }
    }

    func all(for user: User) throws -> EventLoopFuture<[List]> {
        return try all(for: user, sort: FluentListRepository.orderByName)
    }

    func all(
        for user: User,
        sort: ListsSorting
    ) throws -> EventLoopFuture<[List]> {
        let orderBy = try? sort.sqlOrderBy(on: FluentList.self)
            ?? sortingDefault.sqlOrderBy(on: FluentList.self)
        return db.withConnection { connection in
            var query = try user.model.lists.query(on: connection)
            if let orderBy = orderBy {
                query = query.sort(orderBy)
            }
            return query
                .sort(\.title, .ascending)
                .all()
                .mapToEntities()
        }
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return FluentList.query(on: connection)
                .filter(\.userID == userid.uuid)
                .count()
        }
    }

    func count(title: Title, for user: User) throws -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return try user.model.lists.query(on: connection)
                .filter(\.title == title)
                .count()
        }
    }

    func owner(of list: List) -> EventLoopFuture<User> {
        return db.withConnection { connection in
            return list.model.user.get(on: connection)
                .mapToEntity()
        }
    }

    func save(list: List) -> EventLoopFuture<List> {
        return db.withConnection { connection in
            if list.id == nil {
                // list create
                let limit = List.maximumNumberOfListsPerUser
                return FluentList.query(on: connection)
                    .filter(\.userID == list.userID)
                    .count()
                    .max(limit, or: EntityError<List>.limitReached(maximum: limit))
                    .transform(to:
                        list.model.save(on: connection)
                    )
                    .mapToEntity()
            }
            else {
                // list update
                return list.model.save(on: connection)
                    .mapToEntity()
            }
        }
    }

    func delete(list: List, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            guard let userid = user.userID, userid == list.userID else {
                return connection.future(nil)
            }
            return list.model.delete(on: connection)
                .transform(to: list.detached())
        }
    }

    // Returns an available list title for a user based on the specified title
    // by appending an increasing counter to it.
    func available(title: String, for user: User) throws -> EventLoopFuture<String?> {
        return try all(for: user)
            .map { lists in
                var candidate = title

                // build list of existing titles
                let titles = lists.map { list in String(list.title) }

                if titles.contains(candidate) {
                    let prefix = String(title.prefix(List.maximumLengthOfTitle - 4))

                    // append increasing number to title until unique title is found
                    // (counts up to 99)
                    var counter = 0
                    repeat {
                        counter += 1
                        candidate = "\(prefix)_\(counter)"
                    } while titles.contains(candidate) && counter < 99

                    guard counter < 99 else {
                        // counter outrun (no unique name found)
                        return nil
                    }
                }

                return candidate
            }
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == (FluentUser, FluentList)? {

    func mapToEntities() -> EventLoopFuture<(List, User)?> {
        return self.map { models in
            guard let models = models else {
                return nil
            }
            return (List(from: models.1), User(from: models.0))
        }
    }

}
