import Foundation

// MARK: ReservationRepresentation

public struct ReservationRepresentation: Encodable, Equatable {

    public let id: ReservationID?

    public let createdAt: Date

    public init(
        id: ReservationID?,
        createdAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
    }

}
