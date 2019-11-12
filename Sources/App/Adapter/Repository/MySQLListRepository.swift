import Vapor
import Fluent
import FluentMySQL

/// Adapter for port `ListRepository` using MySQL database.
final class MySQLListRepository: ListRepository, MySQLModelRepository {
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

    func find(by id: List.ID) -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return List.find(id, on: connection)
        }
    }

    func find(by id: List.ID, for user: User) throws -> EventLoopFuture<List?> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.id == id).first()
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
        let id = try user.requireID()
        return db.withConnection { connection in
            return List.query(on: connection).filter(\.userID == id).count()
        }
    }

    func count(title: String, for user: User) throws -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.title == title).count()
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
                    } while titles.contains(title) && counter < 4

                    guard counter < 4 else {
                        // counter outrun (no unique name found)
                        return nil
                    }
                }

                return title
            }
    }

    // MARK: Service

    static let serviceSupports: [Any.Type] = [ListRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
