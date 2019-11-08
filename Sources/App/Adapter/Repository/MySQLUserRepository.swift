import Vapor
import Fluent
import FluentMySQL

final class MySQLUserRepository: UserRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(id: User.ID) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return User.find(id, on: connection)
        }
    }

    func find(identification id: Identification) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.identification == id).first()
        }
    }

    func find(subjectId id: String) -> EventLoopFuture<User?> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.subjectId == id).first()
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

    // MARK: Service

    static let serviceSupports: [Any.Type] = [UserRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
