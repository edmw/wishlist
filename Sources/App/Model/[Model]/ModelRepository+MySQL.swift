import Vapor
import Fluent
import FluentMySQL

import Foundation

protocol MySQLModelRepository {

    var db: MySQLDatabase.ConnectionPool { get }

}

extension MySQLModelRepository {

    func future() -> Future<Void> {
        return db.withConnection { connection in
            return connection.future()
        }
    }

    func future<M>(_ value: M) -> Future<M> {
        return db.withConnection { connection in
            return connection.future(value)
        }
    }

    func future<M>(error: Error) -> Future<M> {
        return db.withConnection { connection in
            return connection.future(error: error)
        }
    }

}

extension ModelQuerySortingDirection {

    var sqlDirection: GenericSQLDirection {
        switch self {
        case .ascending:
            return .ascending
        case .descending:
            return .descending
        }
    }

}
