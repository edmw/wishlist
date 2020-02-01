import Domain

import Vapor
import Fluent
import FluentMySQL

extension Visibility: MySQLEnumType {

    public static var mysqlDataType: MySQLDataType {
        return .tinyint
    }

    public static func reflectDecoded() throws -> (Visibility, Visibility) {
        return (.´private´, .friends)
    }

}
