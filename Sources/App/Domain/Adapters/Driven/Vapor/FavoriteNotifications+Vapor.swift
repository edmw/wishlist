import Domain

import Vapor

extension Favorite.Notifications: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        return ([], [.itemCreated])
    }

}
