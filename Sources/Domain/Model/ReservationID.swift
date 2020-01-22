import Foundation

// MARK: ReservationID

public struct ReservationID: Identifier {

    public let rawValue: UUID

    public init(uuid: UUID) {
        self.rawValue = uuid
    }

}
