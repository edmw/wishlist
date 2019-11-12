import Vapor

// MARK: FavoriteContextsBuilder

class FavoriteContextsBuilder {

    let favoriteRepository: FavoriteRepository
    let itemRepository: ItemRepository

    init(_ favoriteRepository: FavoriteRepository, _ itemRepository: ItemRepository) {
        self.favoriteRepository = favoriteRepository
        self.itemRepository = itemRepository
    }

    var user: User?

    var sorting = ListsSorting.ascending(by: \List.title)

    var includeItemsCount: Bool = false

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withSorting(_ sorting: ListsSorting) -> Self {
        self.sorting = sorting
        return self
    }

    @discardableResult
    func includeItemsCount(_ countItems: Bool) -> Self {
        self.includeItemsCount = includeItemsCount
        return self
    }

    func build(on request: Request) throws -> EventLoopFuture<[FavoriteContext]> {
        guard let user = user else {
            throw FavoriteContextsBuilderError.missingRequiredUser
        }

        // First, we query all lists of the user.
        // Next, we map every list to a future of a context.
        // Meanwhile, we query the number of items for every list and add it to each context.
        // Then, we flatten the array of context futures to a future of an array of contexts.
        // Now, we map the future of an array of contexts to the actual array of contexts.
        // (better would be: use a join on the database)
        return try self.favoriteRepository
            .favorites(for: user, sort: sorting)
            .flatMap { lists in
                return lists.map { list in
                    var context = FavoriteContext(for: list)
                    return list.user.get(on: request).flatMap { owner in
                        context.list.ownerName = owner.displayName
                        if self.includeItemsCount {
                            return try self.itemRepository
                                .count(on: list)
                                .map { itemsCount in
                                    context.list.itemsCount = itemsCount
                                    return context
                                }
                        }
                        else {
                            return request.future(context)
                        }
                    }
                }
                .flatten(on: request)
            }
    }

}

enum FavoriteContextsBuilderError: Error {
    case missingRequiredUser
}
