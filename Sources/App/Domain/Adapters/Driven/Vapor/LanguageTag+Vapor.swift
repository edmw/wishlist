import Domain

import Vapor

extension LanguageTag: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ("0", "1")
    }

}
