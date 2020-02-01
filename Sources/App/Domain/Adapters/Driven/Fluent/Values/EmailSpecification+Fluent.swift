import Domain

import Vapor
import Fluent
import FluentMySQL

extension EmailSpecification: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> EmailSpecification {
        return try self.init(string: .convertFromMySQLData(data))
    }

    public static func reflectDecoded() throws -> (EmailSpecification, EmailSpecification) {
        return ("0", "1")
    }

}
