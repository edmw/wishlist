import Domain

import Vapor
import Fluent
import FluentMySQL

/// This extension conforms the user identity to be usable with Fluent MySQL.
extension UserIdentity: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of VARCHAR(255).
    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    /// Simply store the string into the database.
    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    /// Simply read a string from the database.
    public static func convertFromMySQLData(_ data: MySQLData) throws -> UserIdentity {
        return try self.init(string: .convertFromMySQLData(data))
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    public static func reflectDecoded() throws -> (UserIdentity, UserIdentity) {
        return ("0", "1")
    }

}
