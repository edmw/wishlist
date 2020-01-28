import Domain

import Vapor
import Fluent
import FluentMySQL

extension EmailSpecification: MySQLType, ReflectionDecodable {

    public static func reflectDecoded() throws -> (EmailSpecification, EmailSpecification) {
        return (EmailSpecification(string: "0"), EmailSpecification(string: "1"))
    }

}
