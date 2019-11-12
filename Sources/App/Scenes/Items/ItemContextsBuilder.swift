import Vapor

// MARK: ItemContextsBuilder

class ItemContextsBuilder {

    let itemRepository: ItemRepository

    /// Builder for item contexts.
    /// - Parameter itemRepository: Item repository
    init(_ itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    var list: List?

    /// Contexts sorting.
    var sorting = ItemsSorting.ascending(by: \Item.title)

    /// Contexts filtering.
    var isIncluded: ((Item) -> Bool)?

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

    func build(on worker: Worker) throws -> EventLoopFuture<[ItemContext]> {
        guard let list = list else {
            throw ItemContextsBuilderError.missingRequiredList
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
                    ItemContext(for: item, with: reservation)
                }
            }
    }

}

enum ItemContextsBuilderError: Error {
    case missingRequiredList
}
