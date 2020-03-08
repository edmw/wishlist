import Domain

import Vapor
import Fluent
import FluentMySQL

extension ItemsSorting: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

}
