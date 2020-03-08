import Domain

import Vapor

extension ItemsSorting: ReflectionDecodable {

    public static func reflectDecoded() throws -> (ItemsSorting, ItemsSorting) {
        return (.ascending(propertyName: "id"), .descending(propertyName: "id"))
    }

}
