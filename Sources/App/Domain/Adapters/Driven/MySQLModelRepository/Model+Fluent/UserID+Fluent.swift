import Domain

import Vapor
import Fluent
import FluentMySQL

extension UserID: MySQLType, ReflectionDecodable {

    static let uuid1 = UUID(uuid: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
    static let uuid2 = UUID(uuid: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0))

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    public static func reflectDecoded() throws -> (UserID, UserID) {
        return (UserID(uuid: uuid1), UserID(uuid: uuid2))
    }

}
