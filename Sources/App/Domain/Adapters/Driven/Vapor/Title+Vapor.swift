import Domain

import Vapor

extension Title: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Title, Title) {
        return ("0", "1")
    }

}
