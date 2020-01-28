import Domain

import Vapor
import Fluent
import FluentMySQL

/// This extension conforms the identification to be usable with Fluent MySQL.
extension Identification: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of VARBINARY(16).
    public static var mysqlDataType: MySQLDataType {
        return .varbinary(16)
    }

    /// Simply store the uuid into the database.
    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    /// Simply read a uuid from the database.
    public static func convertFromMySQLData(_ data: MySQLData) throws -> Identification {
        return try self.init(uuid: .convertFromMySQLData(data))
    }

    static let uuid1 = UUID(uuid: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
    static let uuid2 = UUID(uuid: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0))

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    public static func reflectDecoded() throws -> (Identification, Identification) {
        return (Identification(uuid: uuid1), Identification(uuid: uuid2))
    }

}
