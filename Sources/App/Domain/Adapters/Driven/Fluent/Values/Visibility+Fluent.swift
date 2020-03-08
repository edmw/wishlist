import Domain

import Vapor
import Fluent
import FluentMySQL

extension Visibility: MySQLEnumType {

    public static var mysqlDataType: MySQLDataType {
        return .tinyint
    }

}
