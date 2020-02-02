import Foundation

// MARK: ListID

public struct ListID: Identifier {

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
