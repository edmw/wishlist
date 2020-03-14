// sourcery:inline:ItemRepresentation.AutoContext

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ItemContext

/// Type which is used in a render context of a page.
/// Encodes a `ItemRepresentation` while converting typed IDs to `ID`.
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
        case isReserved
        case reservationID
        case reservationHolderID
        case isDeletable
        case isReceivable
        case isArchivable
        case isMovable
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
        try container.encode(item.isReserved, forKey: .isReserved)
        try container.encode(ID(item.reservationID)?.string, forKey: .reservationID)
        try container.encode(ID(item.reservationHolderID)?.string, forKey: .reservationHolderID)
        try container.encode(item.isDeletable, forKey: .isDeletable)
        try container.encode(item.isReceivable, forKey: .isReceivable)
        try container.encode(item.isArchivable, forKey: .isArchivable)
        try container.encode(item.isMovable, forKey: .isMovable)
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
// sourcery:end
