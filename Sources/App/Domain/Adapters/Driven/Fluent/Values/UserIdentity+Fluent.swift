import Domain

import Vapor
import Fluent
import FluentMySQL

extension UserIdentity: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    public func convertToMySQLData() -> MySQLData {
        return String(self).convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> UserIdentity {
        return try self.init(string: .convertFromMySQLData(data))
    }

}
