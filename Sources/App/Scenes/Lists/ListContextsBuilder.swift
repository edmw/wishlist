import Vapor

// MARK: ListContextsBuilder

class ListContextsBuilder {

    let listRepository: ListRepository
    let itemRepository: ItemRepository

    /// Builder for list contexts.
    /// - Parameter listRepository: List repository
    /// - Parameter itemRepository: Item repository
    init(_ listRepository: ListRepository, _ itemRepository: ItemRepository) {
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    var user: User?

    /// Contexts sorting.
    var sorting = ListsSorting.ascending(by: \List.title)

    /// Contexts filtering.
    var isIncluded: ((List) -> Bool)?

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
    func filter(_ isIncluded: @escaping (List) -> Bool) -> Self {
        self.isIncluded = isIncluded
        return self
    }

    @discardableResult
    func includeItemsCount(_ includeItemsCount: Bool) -> Self {
        self.includeItemsCount = includeItemsCount
        return self
    }

    func build(on worker: Worker) throws -> EventLoopFuture<[ListContext]> {
        guard let user = user else {
            throw ListContextsBuilderError.missingRequiredUser
        }

        // First, we query all lists of the user.
        // Next, we map every list to a future of a context.
        // Meanwhile, we query the number of items for every list and add it to each context.
        // Then, we flatten the array of context futures to a future of an array of contexts.
        // Now, we map the future of an array of contexts to the actual array of contexts.
        // (better would be: use a join on the database)
        return try self.listRepository
            .all(for: user, sort: sorting)
            .flatMap { allLists in
                let lists: [List]
                if let isIncluded = self.isIncluded {
                    lists = allLists.filter(isIncluded)
                }
                else {
                    lists = allLists
                }
                return try lists.map { list in
                    var context = ListContext(for: list)
                    if self.includeItemsCount {
                        return try self.itemRepository
                            .count(on: list)
                            .map { count in
                                context.itemsCount = count
                                return context
                            }
                    }
                    else {
                        return worker.future(context)
                    }
                }
                .flatten(on: worker)
            }
    }

}

enum ListContextsBuilderError: Error {
    case missingRequiredUser
}
