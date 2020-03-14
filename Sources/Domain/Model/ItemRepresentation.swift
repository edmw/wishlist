import Foundation

import Library

// MARK: ItemRepresentation

public struct ItemRepresentation: Representation, Encodable, Equatable {

    public let id: ItemID?

    public let title: String
    public let text: String
    public let preference: String
    public let createdAt: Date
    public let modifiedAt: Date

    public let url: String?
    public let imageURL: String?
    public let localImageURL: String?

    public let isReserved: Bool
    public let reservationID: ReservationID?
    public let reservationHolderID: Identification?

    public let isDeletable: Bool
    public let isReceivable: Bool
    public let isArchivable: Bool
    public let isMovable: Bool

    init(_ item: Item, with reservation: ReservationModel? = nil) {
        self.id = item.id
        self.title = item.title ??? "�"
        self.text = item.text ??? "�"
        self.preference = String(describing: item.preference)
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.localImageURL = item.localImageURL?.absoluteString
        self.isReserved = reservation != nil
        self.reservationID = reservation?.id
        self.reservationHolderID = reservation?.holder
        self.isDeletable = item.isDeletable(given: reservation)
        self.isReceivable = item.isReceivable(given: reservation)
        self.isArchivable = item.isArchivable(given: reservation)
        self.isMovable = item.isMovable(given: reservation)
    }

}
