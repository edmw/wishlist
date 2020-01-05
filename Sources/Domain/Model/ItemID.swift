import Foundation

public struct ItemID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
