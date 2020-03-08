import Domain

import Vapor
import Fluent
import FluentMySQL

extension Title: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(2_000)
    }

    public func convertToMySQLData() -> MySQLData {
        return String(self).convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> Title {
        return try self.init(string: .convertFromMySQLData(data))
    }

}
