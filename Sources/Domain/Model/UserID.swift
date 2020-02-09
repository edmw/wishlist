import Foundation

// MARK: UserID

public struct UserID: DomainIdentifier {

    let rawValue: UUID

    init(rawValue: UUID) {
        self.rawValue = rawValue
    }

}
