import Domain

import Vapor

extension Identification: ReflectionDecodable {

    static let uuid1 = UUID(uuid: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15))
    static let uuid2 = UUID(uuid: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0))

    public static func reflectDecoded() throws -> (Self, Self) {
        return (Identification(uuid: uuid1), Identification(uuid: uuid2))
    }

}
