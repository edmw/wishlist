import Domain

import Vapor

extension InvitationCode: ReflectionDecodable {

    public static func reflectDecoded() throws -> (InvitationCode, InvitationCode) {
        return ("0", "1")
    }

}
