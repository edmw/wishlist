import Foundation

import Library

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

    init(_ item: Item, with reservation: ReservationModel? = nil) {
        self.id = item.id
        self.title = item.title ??? "�"
        self.text = item.text ??? "�"
        self.preference = String(item.preference)
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.localImageURL = item.localImageURL?.absoluteString
        self.reservationID = reservation?.id
        self.reservationHolderID = reservation?.holder
    }

}
