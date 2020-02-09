import Foundation

// MARK: FavoriteID

public struct FavoriteID: DomainIdentifier {

    let rawValue: UUID

    init(rawValue: UUID) {
        self.rawValue = rawValue
    }

}
