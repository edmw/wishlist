import Domain

import Vapor
import Fluent
import FluentMySQL

extension ItemsSorting: MySQLType, ReflectionDecodable {

    public static var mysqlDataType: MySQLDataType {
        return .varchar(255)
    }

    public static func reflectDecoded() throws -> (ItemsSorting, ItemsSorting) {
        return (.ascending(propertyName: "id"), .descending(propertyName: "id"))
    }

}
