import Foundation

public struct UserID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
