import Domain

import Vapor

extension Invitation.Status: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Invitation.Status, Invitation.Status) {
        return (.open, .revoked)
    }

}
