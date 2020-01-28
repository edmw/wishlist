import Domain

import Vapor
import Fluent
import FluentMySQL

import Foundation

// MARK: MySQLModelRepository

protocol MySQLModelRepository {

    var db: MySQLDatabase.ConnectionPool { get }

}

extension MySQLModelRepository {

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
