import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentFavoriteRepository

/// Adapter for port `FavoriteRepository` using MySQL database.
final class FluentFavoriteRepository: FavoriteRepository, FluentRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Favorites** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: FavoriteID, for user: User) throws -> EventLoopFuture<Favorite?> {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return FluentFavorite.find(id.uuid, on: connection)
                .map { favorite in
                    guard let favorite = favorite, favorite.userID == userid.uuid else {
                        return nil
                    }
                    return favorite
                }
                .mapToEntity()
        }
    }

    func find(favorite list: List, for user: User) throws -> EventLoopFuture<Favorite?> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        return db.withConnection { connection in
            let usermodel = user.model
            // check if the list is a favorite
            return usermodel.favorites.isAttached(list.model, on: connection)
                .flatMap { attached in
                    if attached {
                        // return favorite
                        return try usermodel.favorites.pivots(on: connection)
                            .filter(\.listKey == listid.uuid)
                            .first()
                            .mapToEntity()
                    }
                    else {
                        return connection.future(nil)
                    }
                }
        }
    }

    func favorites(for user: User) throws -> EventLoopFuture<[(Favorite, List)]> {
        return try favorites(for: user, sort: sortingDefault)
    }

    func favorites(
        for user: User,
        sort: ListsSorting
    ) throws -> EventLoopFuture<[(Favorite, List)]> {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let orderBy = try? sort.sqlOrderBy(on: FluentList.self)
            ?? sortingDefault.sqlOrderBy(on: FluentList.self)
        return db.withConnection { connection in
            var query = FluentList.query(on: connection)
                .join(\FluentFavorite.listKey, to: \FluentList.uuid)
                .filter(\FluentFavorite.userKey == userid.uuid)
            if let orderBy = orderBy {
                query = query.sort(orderBy)
            }
            return query
                .sort(\FluentList.title, .ascending)
                .alsoDecode(FluentFavorite.self)
                .all()
                .mapToEntities()
        }
    }

    func favoritesAndUser(for list: List) throws -> EventLoopFuture<[(Favorite, User)]> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        return db.withConnection { connection in
            return FluentFavorite.query(on: connection)
                .join(\FluentUser.uuid, to: \FluentFavorite.userKey)
                .filter(\FluentFavorite.listKey == listid.uuid)
                .alsoDecode(FluentUser.self)
                .all()
                .mapToEntities()
        }
    }

    func addFavorite(_ list: List, for user: User) throws -> EventLoopFuture<Favorite> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            let usermodel = user.model
            // check if the list is already a favorite
            return usermodel.favorites.isAttached(list.model, on: connection)
                .flatMap { attached in
                    if attached {
                        // return existing favorite
                        return try usermodel.favorites.pivots(on: connection)
                            .filter(\.listKey == listid.uuid)
                            .first()
                            .unwrap(or: EntityError<List>.lookupFailed(for: listid))
                            .mapToEntity()
                    }
                    else {
                        // favorite create
                        let limit = Favorite.maximumNumberOfFavoritesPerUser
                        return FluentFavorite.query(on: connection)
                            .filter(\.userKey == userid.uuid)
                            .count()
                            .max(limit, or: EntityError<Reservation>.limitReached(maximum: limit))
                            .transform(to:
                                // attach list and return created favorite
                                usermodel.favorites.attach(list.model, on: connection)
                            )
                            .mapToEntity()
                    }
                }
        }
    }

    func save(favorite: Favorite) -> EventLoopFuture<Favorite> {
        return db.withConnection { connection in
            return favorite.model.save(on: connection)
                .mapToEntity()
        }
    }

    func delete(favorite: Favorite) throws -> EventLoopFuture<Favorite> {
        return db.withConnection { connection in
            return favorite.model.delete(on: connection)
                .transform(to: favorite.detached())
        }
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == [(FluentList, FluentFavorite)] {

    func mapToEntities() -> EventLoopFuture<[(Favorite, List)]> {
        return self.map { models in
            return models.map { model in (Favorite(from: model.1), List(from: model.0)) }
        }
    }

}

extension EventLoopFuture where Expectation == [(FluentFavorite, FluentUser)] {

    func mapToEntities() -> EventLoopFuture<[(Favorite, User)]> {
        return self.map { models in
            return models.map { model in (Favorite(from: model.0), User(from: model.1)) }
        }
    }

}
