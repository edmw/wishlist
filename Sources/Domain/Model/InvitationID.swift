import Foundation

// MARK: InvitationID

public struct InvitationID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
