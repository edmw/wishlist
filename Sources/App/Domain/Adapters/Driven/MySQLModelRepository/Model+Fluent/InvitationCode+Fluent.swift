import Domain

import Vapor
import Fluent
import FluentMySQL

/// This extension conforms the invitation code to be usable with Fluent MySQL.
extension InvitationCode: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of VARCHAR(32).
    public static var mysqlDataType: MySQLDataType {
        return .varchar(32)
    }

    /// Simply store the string into the database.
    public func convertToMySQLData() -> MySQLData {
        return rawValue.convertToMySQLData()
    }

    /// Simply read a string from the database.
    public static func convertFromMySQLData(_ data: MySQLData) throws -> InvitationCode {
        return try self.init(string: .convertFromMySQLData(data))
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    public static func reflectDecoded() throws -> (InvitationCode, InvitationCode) {
        return ("0", "1")
    }

}
