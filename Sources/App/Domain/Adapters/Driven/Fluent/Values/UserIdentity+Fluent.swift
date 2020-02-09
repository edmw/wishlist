import Domain

import Vapor
import Fluent
import FluentMySQL

extension UserIdentity: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    public func convertToMySQLData() -> MySQLData {
        return String(self).convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> UserIdentity {
        return try self.init(string: .convertFromMySQLData(data))
    }

    public static func reflectDecoded() throws -> (UserIdentity, UserIdentity) {
        return ("0", "1")
    }

}
