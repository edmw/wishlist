import Foundation

// MARK: ItemID

public struct ItemID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
