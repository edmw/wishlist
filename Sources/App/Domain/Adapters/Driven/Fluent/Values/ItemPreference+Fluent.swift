import Domain

import Vapor
import Fluent
import FluentMySQL

extension Item.Preference: MySQLEnumType {

    public static var mysqlDataType: MySQLDataType {
        return .tinyint
    }

    public static func reflectDecoded() throws -> (Item.Preference, Item.Preference) {
        return (.low, .high)
    }

}
