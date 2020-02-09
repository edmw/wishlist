import Foundation

// MARK: InvitationID

public struct InvitationID: DomainIdentifier {

    let rawValue: UUID

    init(rawValue: UUID) {
        self.rawValue = rawValue
    }

}
