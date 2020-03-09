import Domain

import Vapor

extension Invitation.Status: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return (.open, .revoked)
    }

}
