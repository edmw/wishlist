import Domain

import Vapor

extension Visibility: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Visibility, Visibility) {
        return (.´private´, .friends)
    }

}
