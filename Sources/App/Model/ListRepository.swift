import Vapor

import Fluent
import FluentMySQL

import Foundation

final class ListsSorting: EntitySorting<List> {}

protocol ListRepository: EntityRepository {

    func find(by id: List.ID) -> Future<List?>
    func find(by id: List.ID, for user: User) throws -> Future<List?>
    func find(name: String) -> Future<List?>
    func find(name: String, for user: User) throws -> Future<List?>

    func all() -> Future<[List]>
    func all(for user: User) throws -> Future<[List]>
    func all(for user: User, sort: ListsSorting) throws -> Future<[List]>

    func count(for user: User) throws -> Future<Int>

    func save(list: List) -> Future<List>

    // Returns an available list name for a user based on the specified name.
    func available(name: String, for user: User) throws -> Future<String?>
}

final class MySQLListRepository: ListRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    // default sort order
    static let orderByNameKeyPath = \List.name
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

    func find(name: String) -> Future<List?> {
        return db.withConnection { connection in
            return List.query(on: connection).filter(\.name == name).first()
        }
    }

    func find(name: String, for user: User) throws -> Future<List?> {
        return db.withConnection { connection in
            return try user.lists.query(on: connection).filter(\.name == name).first()
        }
    }

    func all() -> Future<[List]> {
        return db.withConnection { connection in
            return List.query(on: connection).sort(\.name, .ascending).all()
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
                .sort(\.name, .ascending)
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

    // Returns an available list name for a user based on the specified name
    // by appending an increasing counter to it.
    func available(name string: String, for user: User) throws -> Future<String?> {
        return try all(for: user)
            .map { lists in
                var name = string

                // build list of existing names
                let names = lists.map { list in list.name }

                if names.contains(name) {
                    let prefix = String(name.prefix(List.maximumLengthOfName - 4))

                    // append increasing number to name until unique name is found
                    // (counts up to 99)
                    var counter = 0
                    repeat {
                        counter += 1
                        name = "\(prefix)_\(counter)"
                    } while names.contains(name) && counter < 4

                    guard counter < 4 else {
                        // counter outrun (no unique name found)
                        return nil
                    }
                }

                return name
            }
    }

    // MARK: Service

    static let serviceSupports: [Any.Type] = [ListRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
