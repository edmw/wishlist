import Domain

import Vapor

extension Text: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Text, Text) {
        return ("0", "1")
    }

}
