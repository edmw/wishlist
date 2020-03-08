import Domain

import Vapor

extension EmailSpecification: ReflectionDecodable {

    public static func reflectDecoded() throws -> (EmailSpecification, EmailSpecification) {
        return ("0", "1")
    }

}
