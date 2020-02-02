import Foundation

// MARK: InvitationID

public struct InvitationID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

    public init?(uuid: UUID?) {
        guard let uuid = uuid else {
            return nil
        }
        self.rawValue = uuid
    }

}
