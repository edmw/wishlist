import Domain

import Vapor
import Fluent
import FluentMySQL

extension Identification: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .varbinary(16)
    }

    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> Identification {
        return try self.init(uuid: .convertFromMySQLData(data))
    }

    static let uuid1 = UUID(uuid: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
    static let uuid2 = UUID(uuid: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0))

    public static func reflectDecoded() throws -> (Identification, Identification) {
        return (Identification(uuid: uuid1), Identification(uuid: uuid2))
    }

}
