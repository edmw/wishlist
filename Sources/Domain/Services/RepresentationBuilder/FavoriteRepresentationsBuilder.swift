import Foundation
import NIO

import Library

// MARK: FavoriteRepresentationsBuilder

class FavoriteRepresentationsBuilder {

    let favoriteRepository: FavoriteRepository
    let listRepository: ListRepository
    let itemRepository: ItemRepository

    /// Builder for favorite representations.
    /// - Parameter favoriteRepository: Favorite repository
    /// - Parameter listRepository: List repository
    /// - Parameter itemRepository: Item repository
    init(
        _ favoriteRepository: FavoriteRepository,
        _ listRepository: ListRepository,
        _ itemRepository: ItemRepository
    ) {
        self.favoriteRepository = favoriteRepository
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    var user: User?

    var sorting = ListsSorting.ascending(by: \List.title)

    var includeItemsCount: Bool = false

    func reset() -> Self {
        self.user = nil
        self.sorting = ListsSorting.ascending(by: \List.title)
        self.includeItemsCount = false
        return self
    }

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withSorting(_ sorting: ListsSorting?) -> Self {
        if let sorting = sorting {
            self.sorting = sorting
        }
        return self
    }

    @discardableResult
    func includeItemsCount(_ includeItemsCount: Bool) -> Self {
        self.includeItemsCount = includeItemsCount
        return self
    }

    func build(on worker: EventLoop) throws -> EventLoopFuture<[FavoriteRepresentation]> {
        guard let user = user else {
            throw FavoriteRepresentationsBuilderError.missingRequiredUser
        }

        // First, we query all lists of the user.
        // Next, we map every list to a future of a context.
        // Meanwhile, we query the number of items for every list and add it to each context.
        // Then, we flatten the array of context futures to a future of an array of contexts.
        // Now, we map the future of an array of contexts to the actual array of contexts.
        // (better would be: use a join on the database)
        return try self.favoriteRepository
            .favorites(for: user, sort: sorting)
            .flatMap { favorites in
                return favorites.map { favorite, list in
                    return self.listRepository
                        .owner(of: list)
                        .flatMap { owner in
                            if self.includeItemsCount {
                                return try self.itemRepository
                                    .count(on: list)
                                    .map { itemsCount in
                                        return FavoriteRepresentation(
                                            favorite,
                                            list,
                                            ownerName: owner.displayName,
                                            itemsCount: itemsCount
                                        )
                                    }
                            }
                            else {
                                let representation = FavoriteRepresentation(
                                    favorite,
                                    list,
                                    ownerName: owner.displayName
                                )
                                return worker.makeSucceededFuture(representation)
                            }
                        }
                }
                .flatten(on: worker)
            }
    }

}

enum FavoriteRepresentationsBuilderError: Error {
    case missingRequiredUser
}
