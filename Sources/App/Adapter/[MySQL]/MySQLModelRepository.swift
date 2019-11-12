import Vapor
import Fluent
import FluentMySQL

import Foundation

// MARK: MySQLModelRepository

protocol MySQLModelRepository {

    var db: MySQLDatabase.ConnectionPool { get }

}
