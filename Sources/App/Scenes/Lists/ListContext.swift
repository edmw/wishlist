import Domain

import Foundation

/// Type which is used in a render context of a page. The reason why `ListRepresentation` is not
/// used directly is, the id property has to be converted from `ListID` to `ID`.
struct ListContext: Encodable {

    let list: ListRepresentation

    let id: ID?

    enum Keys: String, CodingKey {
        case id
        case title
        case visibility
        case createdAt
        case modifiedAt
        case maskReservations
        case itemsSorting
        case ownerName
        case itemsCount
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(id?.string, forKey: .id)
        try container.encode(list.title, forKey: .title)
        try container.encode(list.visibility, forKey: .visibility)
        try container.encode(list.createdAt, forKey: .createdAt)
        try container.encode(list.modifiedAt, forKey: .modifiedAt)
        try container.encode(list.maskReservations, forKey: .maskReservations)
        try container.encode(list.itemsSorting, forKey: .itemsSorting)
        try container.encode(list.ownerName, forKey: .ownerName)
        try container.encode(list.itemsCount, forKey: .itemsCount)
    }

    init(_ list: ListRepresentation) {
        self.list = list
        self.id = ID(list.id)
    }

    init?(_ list: ListRepresentation?) {
        guard let list = list else {
            return nil
        }
        self.init(list)
    }

}
