import Domain

import Vapor
import Fluent
import FluentMySQL

extension Invitation.Status: MySQLEnumType {

    public static var mysqlDataType: MySQLDataType {
        return .tinyint
    }

    public static func reflectDecoded() throws -> (Invitation.Status, Invitation.Status) {
        return (.open, .revoked)
    }

}
