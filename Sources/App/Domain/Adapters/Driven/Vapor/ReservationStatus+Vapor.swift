import Domain

import Vapor

extension Reservation.Status: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return (.open, .closed)
    }

}
