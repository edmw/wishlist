import Domain

import Vapor
import Fluent
import FluentMySQL

extension LanguageTag: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(64)
    }

    public func convertToMySQLData() -> MySQLData {
        return String(self).convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> LanguageTag {
        return try self.init(string: .convertFromMySQLData(data))
    }

    public static func reflectDecoded() throws -> (LanguageTag, LanguageTag) {
        return ("0", "1")
    }

}
