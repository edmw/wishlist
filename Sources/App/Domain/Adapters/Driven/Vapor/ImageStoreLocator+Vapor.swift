import Domain

import Vapor

extension ImageStoreLocator: ReflectionDecodable {

    public static func reflectDecoded() throws -> (Self, Self) {
        let locator1 = ImageStoreLocator(url: URL(fileURLWithPath: "/a"))
        let locator2 = ImageStoreLocator(url: URL(fileURLWithPath: "/b"))
        return (locator1, locator2)
    }

}
