import Domain

import Vapor
import Fluent
import FluentMySQL

/// This extension conforms the user identity provider to be usable with Fluent MySQL.
extension UserIdentityProvider: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of VARCHAR(255).
    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    /// Simply store the string into the database.
    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    /// Simply read a string from the database.
    public static func convertFromMySQLData(_ data: MySQLData) throws -> UserIdentityProvider {
        return try self.init(string: .convertFromMySQLData(data))
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    public static func reflectDecoded() throws -> (UserIdentityProvider, UserIdentityProvider) {
        return ("0", "1")
    }

}
