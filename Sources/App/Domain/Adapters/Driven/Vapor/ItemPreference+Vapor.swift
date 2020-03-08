import Domain

import Vapor

extension Item.Preference: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Item.Preference, Item.Preference) {
        return (.low, .high)
    }

}
