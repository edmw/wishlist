import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: MySQLUserRepository

/// Adapter for port `UserRepository` using MySQL database.
final class MySQLUserRepository: UserRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Users** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(id: UserID) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return User.find(id.uuid, on: connection)
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
            return User.query(on: connection).filter(\.identification == id).first()
        }
    }

    func find(identity: UserIdentity, of provider: UserIdentityProvider) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return User.query(on: connection)
                .filter(\.identity == identity)
                .filter(\.identityProvider == provider)
                .first()
        }
    }

    func find(nickName: String) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.nickName == nickName).first()
        }
    }

    func all() -> EventLoopFuture<[User]> {
        return db.withConnection { connection in
            return User.query(on: connection).all()
        }
    }

    func count() -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return User.query(on: connection).count()
        }
    }

    func count(nickName: String) -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.nickName == nickName).count()
        }
    }

    func save(user: User) -> EventLoopFuture<User> {
        return db.withConnection { connection in
            return user.save(on: connection)
        }
    }

}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
