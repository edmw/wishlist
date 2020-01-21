import DomainModel
import Library

// MARK: ItemRepresentation

extension ItemRepresentation {

    internal init(_ item: Item, with reservation: Reservation? = nil) {
        self.init(
            id: item.itemID,
            title: item.title ??? "�",
            text: item.text ??? "�",
            preference: String(describing: item.preference),
            createdAt: item.createdAt,
            modifiedAt: item.modifiedAt,
            url: item.url?.absoluteString,
            imageURL: item.imageURL?.absoluteString,
            localImageURL: item.localImageURL?.absoluteString,
            reservationID: reservation?.reservationID,
            reservationHolderID: reservation?.holder
        )
    }

}
