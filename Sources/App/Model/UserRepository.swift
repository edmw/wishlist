import Vapor

import Fluent
import FluentMySQL

import Foundation

protocol UserRepository: ModelRepository {

    func find(id: User.ID) -> Future<User?>
    func find(identification: Identification) -> Future<User?>
    func find(subjectId id: String) -> Future<User?>
    func find(nickName: String) -> Future<User?>

    func all() -> Future<[User]>

    func save(user: User) -> Future<User>

}

final class MySQLUserRepository: UserRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(id: User.ID) -> Future<User?> {
        return db.withConnection { connection in
            return User.find(id, on: connection)
        }
    }

    func find(identification id: Identification) -> Future<User?> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.identification == id).first()
        }
    }

    func find(subjectId id: String) -> Future<User?> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.subjectId == id).first()
        }
    }

    func find(nickName: String) -> Future<User?> {
        return db.withConnection { connection in
            return User.query(on: connection).filter(\.nickName == nickName).first()
        }
    }

    func all() -> Future<[User]> {
        return db.withConnection { connection in
            return User.query(on: connection).all()
        }
    }

    func save(user: User) -> Future<User> {
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
