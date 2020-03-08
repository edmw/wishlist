import Domain

import Vapor

extension UserIdentity: ReflectionDecodable {

    public static func reflectDecoded() throws -> (UserIdentity, UserIdentity) {
        return ("0", "1")
    }

}
