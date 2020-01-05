import Domain

import Foundation

/// Type which is used in a render context of a page. The reason why `ItemRepresentation` is not
/// used directly is, the id property has to be converted from `ItemID` to `ID`.
struct ItemContext: Encodable {

    let item: ItemRepresentation

    let id: ID?

    enum Keys: String, CodingKey {
        case id
        case title
        case text
        case preference
        case createdAt
        case modifiedAt
        case url
        case imageURL
        case localImageURL
        case reservationID
        case reservationHolderID
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(id?.string, forKey: .id)
        try container.encode(item.title, forKey: .title)
        try container.encode(item.text, forKey: .text)
        try container.encode(item.preference, forKey: .preference)
        try container.encode(item.createdAt, forKey: .createdAt)
        try container.encode(item.modifiedAt, forKey: .modifiedAt)
        try container.encode(item.url, forKey: .url)
        try container.encode(item.imageURL, forKey: .imageURL)
        try container.encode(item.localImageURL, forKey: .localImageURL)
        try container.encode(ID(item.reservationID)?.string, forKey: .reservationID)
        try container.encode(ID(item.reservationHolderID)?.string, forKey: .reservationHolderID)
    }

    init(_ item: ItemRepresentation) {
        self.item = item
        self.id = ID(item.id)
    }

    init?(_ item: ItemRepresentation?) {
        guard let item = item else {
            return nil
        }
        self.init(item)
    }

}
