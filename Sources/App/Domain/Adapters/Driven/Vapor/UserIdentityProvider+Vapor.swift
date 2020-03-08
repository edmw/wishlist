import Domain

import Vapor

extension UserIdentityProvider: ReflectionDecodable {

    public static func reflectDecoded() throws -> (UserIdentityProvider, UserIdentityProvider) {
        return ("0", "1")
    }

}
