import Library

import Foundation

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

    public init(
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

}
