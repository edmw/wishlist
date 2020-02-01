import Domain

import Vapor
import Fluent
import FluentMySQL

import Foundation

// MARK: FluentRepository

protocol FluentRepository {

    var db: MySQLDatabase.ConnectionPool { get }

}

extension FluentRepository {

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return db.withConnection { connection -> EventLoopFuture<T> in
            return connection.future(value)
        }
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return db.withConnection { connection -> EventLoopFuture<T> in
            return connection.future(error: error)
        }
    }

}

extension Fluent.Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
