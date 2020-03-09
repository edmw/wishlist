import Domain

import Vapor

extension Visibility: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return (.´private´, .friends)
    }

}
