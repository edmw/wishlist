import Vapor
import Fluent
import FluentMySQL

extension Visibility: MySQLEnumType {

    static func reflectDecoded() throws -> (Visibility, Visibility) {
        return (.´private´, .friends)
    }

}
