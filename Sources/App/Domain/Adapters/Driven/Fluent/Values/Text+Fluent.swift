import Domain

import Vapor
import Fluent
import FluentMySQL

extension Text: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .longtext
    }

    public func convertToMySQLData() -> MySQLData {
        return String(self).convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> Text {
        return try self.init(string: .convertFromMySQLData(data))
    }

    public static func reflectDecoded() throws -> (Text, Text) {
        return ("0", "1")
    }

}
