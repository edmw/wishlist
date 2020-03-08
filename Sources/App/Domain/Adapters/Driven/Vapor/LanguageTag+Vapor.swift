import Domain

import Vapor

extension LanguageTag: ReflectionDecodable {

    public static func reflectDecoded() throws -> (LanguageTag, LanguageTag) {
        return ("0", "1")
    }

}
