import Foundation

import Library

// MARK: ListRepresentation

public struct ListRepresentation: Representation, Encodable, Equatable {

    public let id: ListID?

    public let title: String
    public let visibility: String
    public let createdAt: Date
    public let modifiedAt: Date
    public let maskReservations: Bool

    public var ownerName: String?

    public let itemsSorting: String?

    public var itemsCount: Int?

    init(_ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.id = list.id
        self.title = list.title ??? "�"
        self.visibility = String(list.visibility)
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt
        self.maskReservations = list.options.contains(.maskReservations)
        self.ownerName = ownerName
        self.itemsSorting = list.itemsSorting.map { String(describing: $0) }
        self.itemsCount = itemsCount
    }

}
