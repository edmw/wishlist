import Foundation
import NIO

struct ItemService {

    /// Repository for Items to be used by this service.
    let itemRepository: ItemRepository

    /// Initializes an Item service.
    /// - Parameter itemRepository: Repository for Items to be used by this service.
    init(_ itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    /// Deletes all items of the specified list. Removes the associated images, too. First, checks
    /// if any of the items is reserved and throws an error then.
    /// - Parameter list: List containing the items to be deleted.
    /// - Parameter imageStore: ImageStore containing the images for the items.
    func deleteItems(for list: List, imageStore: ImageStoreProvider) throws
        -> EventLoopFuture<List>
    {
        return try itemRepository.allAndReservations(for: list)
            .flatMap { itemsAndReservations in
                // check if there is at least one item reserved in the list of items
                let reserved = itemsAndReservations.contains { itemAndReservation in
                    itemAndReservation.1 != nil
                }
                guard reserved == false else {
                    // do not delete any items from a list that contains a reserved item
                    throw ItemServiceError.deleteItemsHasReservedItems
                }
                let items = itemsAndReservations.map { $0.0 }
                // remove images for items
                for item in items {
                    try imageStore.removeImages(for: item)
                }
                // delete items
                // this call is expensive (deleting one by one)
                return try self.itemRepository.delete(items: items, in: list)
                    .transform(to: list)
            }
    }

}

/// Errors thrown by the Item Service.
enum ItemServiceError: Error {
    /// List items can be deleted if there is no reserved item, only.
    case deleteItemsHasReservedItems
}
