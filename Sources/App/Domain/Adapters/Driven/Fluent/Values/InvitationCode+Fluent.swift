import Domain

import Vapor
import Fluent
import FluentMySQL

extension InvitationCode: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(32)
    }

    public func convertToMySQLData() -> MySQLData {
        return String(self).convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> InvitationCode {
        return try self.init(string: .convertFromMySQLData(data))
    }

}
