import Foundation

import Library

// MARK: ListRepresentation

public struct ListRepresentation: Encodable, Equatable {

    public let id: ListID?

    public let title: String
    public let visibility: String
    public let createdAt: Date
    public let modifiedAt: Date
    public let maskReservations: Bool

    public var ownerName: String?

    public let itemsSorting: String?

    public var itemsCount: Int?

    init(
        id: ListID?,
        title: String,
        visibility: String,
        createdAt: Date,
        modifiedAt: Date,
        maskReservations: Bool,
        ownerName: String?,
        itemsSorting: String?,
        itemsCount: Int?
    ) {
        self.id = id
        self.title = title
        self.visibility = visibility
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.maskReservations = maskReservations
        self.ownerName = ownerName
        self.itemsSorting = itemsSorting
        self.itemsCount = itemsCount
    }

    init(_ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.init(
            id: list.id,
            title: list.title ??? "�",
            visibility: String(describing: list.visibility),
            createdAt: list.createdAt,
            modifiedAt: list.modifiedAt,
            maskReservations: list.options.contains(.maskReservations),
            ownerName: ownerName,
            itemsSorting: list.itemsSorting.map { String(describing: $0) },
            itemsCount: itemsCount
        )
    }

}
