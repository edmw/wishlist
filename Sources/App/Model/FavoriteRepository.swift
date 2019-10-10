import Vapor

import Fluent
import FluentMySQL

import Foundation

protocol FavoriteRepository: ModelRepository {

    func find(by id: Favorite.ID, for user: User) throws -> Future<Favorite?>
    func find(favorite list: List, for user: User) throws -> Future<Favorite?>

    func favorites(for user: User) throws -> Future<[List]>
    func favorites(for user: User, sort: ListsSorting) throws -> Future<[List]>

    func addFavorite(_ list: List, for user: User) throws -> Future<Favorite>

}

final class MySQLFavoriteRepository: FavoriteRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: Favorite.ID, for user: User) throws -> Future<Favorite?> {
        return db.withConnection { connection in
            return Favorite.find(id, on: connection).map { favorite in
                guard let favorite = favorite, favorite.userID == user.id else {
                    return nil
                }
                return favorite
            }
        }
    }

    func find(favorite list: List, for user: User) throws -> Future<Favorite?> {
        guard let listID = list.id else {
            throw ModelError<List>.requiredIDMissing
        }
        return db.withConnection { connection in
            // check if the list is a favorite
            return user.favorites.isAttached(list, on: connection)
                .flatMap { attached in
                    if attached {
                        // return favorite
                        return try user.favorites.pivots(on: connection)
                            .filter(\.listID == listID)
                            .first()
                    }
                    else {
                        return connection.future(nil)
                    }
                }
        }
    }

    func favorites(for user: User) throws -> Future<[List]> {
        return try favorites(for: user, sort: MySQLListRepository.orderByName)
    }

    func favorites(
        for user: User,
        sort: ListsSorting
    ) throws -> Future<[List]> {
        return db.withConnection { connection in
            let orderBy = (try? sort.orderBy(on: List.self)) ???? MySQLListRepository.orderByNameSql
            return try user.favorites
                .query(on: connection)
                .sort(orderBy)
                .sort(\.title, .ascending)
                .all()
        }
    }

    /// Adds the specified list to the list of favorite lists for the specified user.
    func addFavorite(_ list: List, for user: User) throws -> Future<Favorite> {
        guard let listID = list.id else {
            throw ModelError<List>.requiredIDMissing
        }
        return db.withConnection { connection in
            // check if the list is already a favorite
            return user.favorites.isAttached(list, on: connection)
                .flatMap { attached in
                    if attached {
                        // return existing favorite
                        return try user.favorites.pivots(on: connection)
                            .filter(\.listID == listID)
                            .first()
                            .unwrap(or: EntityError<List>.lookupFailed(for: listID))
                    }
                    else {
                        // attach list and return created favorite
                        return user.favorites.attach(list, on: connection)
                    }
                }
        }
    }

    // MARK: Service

    static let serviceSupports: [Any.Type] = [FavoriteRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
