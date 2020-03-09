import Domain

import Vapor

extension Item.Preference: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return (.low, .high)
    }

}
