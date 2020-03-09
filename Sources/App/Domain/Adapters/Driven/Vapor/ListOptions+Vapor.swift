import Domain

import Vapor

extension List.Options: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ([], [.maskReservations])
    }

}
