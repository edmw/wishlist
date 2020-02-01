import Domain

import Vapor
import Fluent
import FluentMySQL

extension List.Options: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .smallint()
    }

    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    public static func convertFromMySQLData(_ data: MySQLData) throws -> List.Options {
        return try self.init(rawValue: .convertFromMySQLData(data))
    }

    public static func reflectDecoded() throws -> (List.Options, List.Options) {
        return ([], [.maskReservations])
    }

}
