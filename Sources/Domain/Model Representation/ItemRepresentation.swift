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

    internal init(_ item: Item, with reservation: Reservation? = nil) {
        self.id = item.itemID

        self.title = item.title ??? "�"
        self.text = item.text ??? "�"
        self.preference = String(describing: item.preference)
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt

        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.localImageURL = item.localImageURL?.absoluteString

        self.reservationID = reservation?.reservationID
        self.reservationHolderID = reservation?.holder
    }

}

extension Item {

    /// Returns a representation for this model.
    var representation: ItemRepresentation {
        return .init(self)
    }

    /// Returns a representation for this model together with the given reservation.
    func representation(with reservation: Reservation?) -> ItemRepresentation {
        return .init(self, with: reservation)
    }

}
