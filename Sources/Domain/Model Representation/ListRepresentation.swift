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

    public let itemsSorting: String?

    public internal(set) var ownerName: String?

    public internal(set) var itemsCount: Int?

    internal init(_ list: List) {
        self.id = list.listID

        self.title = list.title ??? "�"
        self.visibility = String(describing: list.visibility)
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt
        self.maskReservations = list.options.contains(.maskReservations)
        if let listItemsSorting = list.itemsSorting {
            self.itemsSorting = String(describing: listItemsSorting)
        }
        else {
            self.itemsSorting = nil
        }
    }

}

extension List {

    /// Returns a representation for this model.
    var representation: ListRepresentation {
        return .init(self)
    }

}
