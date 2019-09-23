import Vapor

import Fluent
import FluentMySQL

import Foundation

final class ListsSorting: EntitySorting<List> {}

protocol ListRepository: EntityRepository {

    func find(by id: List.ID) -> Future<List?>
    func find(by id: List.ID, for user: User) throws -> Future<List?>
    func find(title: String) -> Future<List?>
    func find(title: String, for user: User) throws -> Future<List?>

    func all() -> Future<[List]>
    func all(for user: User) throws -> Future<[List]>
    func all(for user: User, sort: ListsSorting) throws -> Future<[List]>

    func count(for user: User) throws -> Future<Int>

    func save(list: List) -> Future<List>

    // Returns an available list title for a user based on the specified title.
    func available(title: String, for user: User) throws -> Future<String?>
}

final class MySQLListRepository: ListRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    // default sort order
    static let orderByNameKeyPath = \List.title
    static let orderByNameDirection = ModelQuerySortingDirection.ascending
    static let orderByName = ListsSorting(orderByNameKeyPath, orderByNameDirection)
    static let orderByNameSql = MySQLDatabase.querySort(
        MySQLDatabase.queryField(.keyPath(orderByNameKeyPath)),
        orderByNameDirection.sqlDirection
    )

    func find(by id: List.ID) -> Future<List?> {
        return db.withConnection { connection in
            return List.find(id, on: connection)
        }
    }

    func find(by id: List.ID, for user: User) throws -> Future<List?> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.id == id).first()
        }
    }

    func find(title: String) -> Future<List?> {
        return db.withConnection { connection in
            return List.query(on: connection).filter(\.title == title).first()
        }
    }

    func find(title: String, for user: User) throws -> Future<List?> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.title == title).first()
        }
    }

    func all() -> Future<[List]> {
        return db.withConnection { connection in
            return List.query(on: connection).sort(\.title, .ascending).all()
        }
    }

    func all(for user: User) throws -> Future<[List]> {
        return try all(for: user, sort: MySQLListRepository.orderByName)
    }

    func all(
        for user: User,
        sort: ListsSorting
    ) throws -> Future<[List]> {
        return db.withConnection { connection in
            let orderBy = (try? sort.orderBy(on: List.self)) ???? MySQLListRepository.orderByNameSql
            return try user.lists
                .query(on: connection)
                .sort(orderBy)
                .sort(\.title, .ascending)
                .all()
        }
    }

    func count(for user: User) throws -> Future<Int> {
        let id = try user.requireID()
        return db.withConnection { connection in
            return List.query(on: connection).filter(\.userID == id).count()
        }
    }

    func save(list: List) -> Future<List> {
        return db.withConnection { connection in
            if list.id == nil {
                // list create
                return List.query(on: connection)
                    .filter(\.userID == list.userID)
                    .count()
                    .flatMap { count in
                        let maximum = List.maximumNumberOfListsPerUser
                        guard count < maximum else {
                            throw EntityError<List>.limitReached(maximum: maximum)
                        }
                        return list.save(on: connection)
                    }
            }
            else {
                // list update
                return list.save(on: connection)
            }
        }
    }

    // Returns an available list title for a user based on the specified title
    // by appending an increasing counter to it.
    func available(title string: String, for user: User) throws -> Future<String?> {
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
