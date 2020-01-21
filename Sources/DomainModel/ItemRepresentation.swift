import Library

import Foundation

// MARK: ItemRepresentation

public struct ItemRepresentation: Encodable, Equatable {

    public let id: ItemID?

    public let title: String
    public let text: String
    public let preference: String
    public let createdAt: Date
    public let modifiedAt: Date

    public let url: String?
    public let imageURL: String?
    public let localImageURL: String?

    public let reservationID: ReservationID?
    public let reservationHolderID: Identification?

    public init(
        id: ItemID?,
        title: String,
        text: String,
        preference: String,
        createdAt: Date,
        modifiedAt: Date,
        url: String?,
        imageURL: String?,
        localImageURL: String?,
        reservationID: ReservationID?,
        reservationHolderID: Identification?
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.preference = preference
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.url = url
        self.imageURL = imageURL
        self.localImageURL = localImageURL
        self.reservationID = reservationID
        self.reservationHolderID = reservationHolderID
    }

}
