import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentUserRepository

/// Adapter for port `UserRepository` using MySQL database.
final class FluentUserRepository: UserRepository, FluentRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Users** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(id: UserID) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return FluentUser.find(id.uuid, on: connection)
                .mapToEntity()
        }
    }

    func findIf(id: UserID?) -> EventLoopFuture<User?> {
        guard let id = id else {
            return future(nil)
        }
        return find(id: id)
    }

    func find(identification id: Identification) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .filter(\.identification == id)
                .first()
                .mapToEntity()
        }
    }

    func find(identity: UserIdentity, of provider: UserIdentityProvider) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .filter(\.identity == identity)
                .filter(\.identityProvider == provider)
                .first()
                .mapToEntity()
        }
    }

    func find(nickName: String) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .filter(\.nickName == nickName)
                .first()
                .mapToEntity()
        }
    }

    func all() -> EventLoopFuture<[User]> {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .all()
                .mapToEntities()
        }
    }

    func count() -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .count()
        }
    }

    func count(nickName: String) -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return FluentUser.query(on: connection)
                .filter(\.nickName == nickName)
                .count()
        }
    }

    func save(user: User) -> EventLoopFuture<User> {
        return db.withConnection { connection in
            return user.model.save(on: connection)
                .mapToEntity()
        }
    }

}
