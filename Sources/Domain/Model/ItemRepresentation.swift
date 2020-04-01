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
    public let archival: Bool

    public let url: String?
    public let imageURL: String?
    public let localImageURL: String?

    // the following properties are optional and only valid if there was a reservation given
    // (or explicitly omitted) when creating the representation

    public let isReserved: Bool?
    public let reservationID: ReservationID?
    public let reservationHolderID: Identification?
    public let isReceived: Bool?

    public let deletable: Bool?
    public let archivable: Bool?
    public let movable: Bool?
    public let receivable: Bool?

    init(_ item: Item) {
        self.init(item, with: nil, withReservation: false)
    }

    init(_ item: Item, with reservation: ReservationModel?) {
        self.init(item, with: reservation, withReservation: true)
    }

    init(_ item: Item, with reservation: ReservationModel?, withReservation: Bool) {
        self.id = item.id
        self.title = item.title ??? "�"
        self.text = item.text ??? "�"
        self.preference = String(describing: item.preference)
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
        self.archival = item.archival
        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.localImageURL = item.localImageURL?.absoluteString
        self.isReserved = withReservation ? item.isReserved(given: reservation) : nil
        self.reservationID = withReservation ? reservation?.id : nil
        self.reservationHolderID = withReservation ? reservation?.holder : nil
        self.isReceived = withReservation ? item.isReceived(given: reservation) : nil
        self.deletable = withReservation ? item.deletable(given: reservation) : nil
        self.archivable = withReservation ? item.archivable(given: reservation) : nil
        self.movable = withReservation ? item.movable(given: reservation) : nil
        self.receivable = withReservation ? item.receivable(given: reservation) : nil
    }

}
