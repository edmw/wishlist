import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: MySQLFavoriteRepository

/// Adapter for port `FavoriteRepository` using MySQL database.
final class MySQLFavoriteRepository: FavoriteRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Favorites** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: FavoriteID, for user: User) throws -> EventLoopFuture<Favorite?> {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return Favorite.find(id.uuid, on: connection).map { favorite in
                guard let favorite = favorite, favorite.userID == userid.uuid else {
                    return nil
                }
                return favorite
            }
        }
    }

    func find(favorite list: List, for user: User) throws -> EventLoopFuture<Favorite?> {
        guard let listid = list.listID else {
            throw EntityError<List>.requiredIDMissing
        }
        return db.withConnection { connection in
            // check if the list is a favorite
            return user.favorites.isAttached(list, on: connection)
                .flatMap { attached in
                    if attached {
                        // return favorite
                        return try user.favorites.pivots(on: connection)
                            .filter(\.listID == listid.uuid)
                            .first()
                    }
                    else {
                        return connection.future(nil)
                    }
                }
        }
    }

    func favorites(for user: User) throws -> EventLoopFuture<[List]> {
        return try favorites(for: user, sort: MySQLListRepository.orderByName)
    }

    func favorites(
        for user: User,
        sort: ListsSorting
    ) throws -> EventLoopFuture<[List]> {
        return db.withConnection { connection in
            let orderBy = (try? sort.sqlOrderBy(on: List.self))
                                ???? MySQLListRepository.orderByNameSql
            return try user.favorites
                .query(on: connection)
                .sort(orderBy)
                .sort(\.title, .ascending)
                .all()
        }
    }

    func addFavorite(_ list: List, for user: User) throws -> EventLoopFuture<Favorite> {
        guard let listid = list.listID else {
            throw EntityError<List>.requiredIDMissing
        }
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            // check if the list is already a favorite
            return user.favorites.isAttached(list, on: connection)
                .flatMap { attached in
                    if attached {
                        // return existing favorite
                        return try user.favorites.pivots(on: connection)
                            .filter(\.listID == listid.uuid)
                            .first()
                            .unwrap(or: EntityError<List>.lookupFailed(for: listid))
                    }
                    else {
                        // favorite create
                        let limit = Favorite.maximumNumberOfFavoritesPerUser
                        return Favorite.query(on: connection)
                            .filter(\.userID == userid.uuid)
                            .count()
                            .max(limit, or: EntityError<Reservation>.limitReached(maximum: limit))
                            .transform(to:
                                // attach list and return created favorite
                                user.favorites.attach(list, on: connection)
                            )
                    }
                }
        }
    }

    func deleteFavorite(_ favorite: Favorite) throws -> EventLoopFuture<Favorite> {
        return db.withConnection { connection in
            return favorite.delete(on: connection)
                .transform(to: favorite.detached())
        }
    }

}
