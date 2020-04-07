import Domain

import Vapor
import Fluent
import FluentMySQL

extension Favorite.Notifications: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .smallint()
    }

    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> Favorite.Notifications {
        return try self.init(rawValue: .convertFromMySQLData(data))
    }

}
