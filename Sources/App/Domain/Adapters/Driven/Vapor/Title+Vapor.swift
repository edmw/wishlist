import Domain

import Vapor

extension Title: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ("0", "1")
    }

}
