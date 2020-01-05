import Foundation
import NIO

// MARK: ItemRepresentationsBuilder

class ItemRepresentationsBuilder {

    let itemRepository: ItemRepository

    /// Builder for item representations.
    /// - Parameter itemRepository: Item repository
    init(_ itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    var list: List?

    /// Sorting
    var sorting = ItemsSorting.ascending(by: \Item.title)

    /// Filtering
    var isIncluded: ((Item) -> Bool)?

    func reset() -> Self {
        self.list = nil
        self.sorting = ItemsSorting.ascending(by: \Item.title)
        self.isIncluded = nil
        return self
    }

    @discardableResult
    func forList(_ list: List) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withSorting(_ sorting: ItemsSorting) -> Self {
        self.sorting = sorting
        return self
    }

    @discardableResult
    func filter(_ isIncluded: @escaping (Item) -> Bool) -> Self {
        self.isIncluded = isIncluded
        return self
    }

    func build(on worker: EventLoop) throws -> EventLoopFuture<[ItemRepresentation]> {
        guard let list = list else {
            throw ItemRepresentationsBuilderError.missingRequiredList
        }

        return try self.itemRepository
            .allAndReservations(for: list, sort: sorting)
            .map { allItemsAndReservations in
                let itemsAndReservations: [(Item, Reservation?)]
                if let isIncluded = self.isIncluded {
                    itemsAndReservations = allItemsAndReservations.filter { item, _ in
                        return isIncluded(item)
                    }
                }
                else {
                    itemsAndReservations = allItemsAndReservations
                }
                return itemsAndReservations.map { item, reservation in
                    item.representation(with: reservation)
                }
            }
    }

}

enum ItemRepresentationsBuilderError: Error {
    case missingRequiredList
}
