import Foundation

public struct FavoriteID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
