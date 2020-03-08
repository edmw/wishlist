import Domain

import Vapor

extension List.Options: ReflectionDecodable {

    public static func reflectDecoded() throws -> (List.Options, List.Options) {
        return ([], [.maskReservations])
    }

}
