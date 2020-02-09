import Foundation

// MARK: ReservationID

public struct ReservationID: DomainIdentifier {

    let rawValue: UUID

    init(rawValue: UUID) {
        self.rawValue = rawValue
    }

}
