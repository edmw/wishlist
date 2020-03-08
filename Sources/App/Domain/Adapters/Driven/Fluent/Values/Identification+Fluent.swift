import Domain

import Vapor
import Fluent
import FluentMySQL

extension Identification: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .varbinary(16)
    }

    public func convertToMySQLData() -> MySQLData {
        return uuid.convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> Identification {
        return try self.init(uuid: .convertFromMySQLData(data))
    }

}
