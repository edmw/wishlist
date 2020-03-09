import Domain

import Vapor

extension EmailSpecification: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ("0", "1")
    }

}
