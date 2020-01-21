import DomainModel
import Library

// MARK: ListRepresentation

extension ListRepresentation {

    internal init(_ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.init(
            id: list.listID,
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
