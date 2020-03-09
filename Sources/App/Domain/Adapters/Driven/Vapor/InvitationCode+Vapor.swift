import Domain

import Vapor

extension InvitationCode: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ("0", "1")
    }

}
