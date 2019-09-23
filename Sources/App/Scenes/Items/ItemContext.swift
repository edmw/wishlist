import Foundation

struct ItemContext: Encodable {

    var id: ID?

    var title: String
    var text: String
    var preference: Int
    var createdAt: Date
    var modifiedAt: Date

    var url: String?
    var imageURL: String?

    var reservationID: ID?
    var reservationHolderID: ID?

    init(for item: Item, with reservation: Reservation? = nil) {
        self.id = ID(item.id)

        self.title = item.title ??? "�"
        self.text = item.text ??? "�"
        self.preference = item.preference.rawValue
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt

        self.url = item.url?.absoluteString
        self.imageURL = item.localImageURL?.absoluteString

        self.reservationID = ID(reservation?.id)
        self.reservationHolderID = ID(reservation?.holder)
    }

}
