import Domain

import Vapor
import Fluent
import FluentMySQL

extension Reservation.Status: MySQLEnumType {

    public static var mysqlDataType: MySQLDataType {
        return .tinyint
    }

}
