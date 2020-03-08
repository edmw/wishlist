import Domain

import Vapor
import Fluent
import FluentMySQL

extension Item.Preference: MySQLEnumType {

    public static var mysqlDataType: MySQLDataType {
        return .tinyint
    }

}
