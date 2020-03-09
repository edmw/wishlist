import Domain

import Vapor

extension UserIdentityProvider: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ("0", "1")
    }

}
