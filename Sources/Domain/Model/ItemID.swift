import Foundation

// MARK: ItemID

public struct ItemID: DomainIdentifier {

    let rawValue: UUID

    init(rawValue: UUID) {
        self.rawValue = rawValue
    }

}
