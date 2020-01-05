import Foundation
import NIO

// MARK: ListRepresentationsBuilder

class ListRepresentationsBuilder {

    let listRepository: ListRepository
    let itemRepository: ItemRepository

    /// Builder for list representation.
    /// - Parameter listRepository: List repository
    /// - Parameter itemRepository: Item repository
    init(_ listRepository: ListRepository, _ itemRepository: ItemRepository) {
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    var user: User?

    /// Sorting
    var sorting = ListsSorting.ascending(by: \List.title)

    /// Filtering
    var isIncluded: ((List) -> Bool)?

    var includeItemsCount: Bool = false

    func reset() -> Self {
        self.user = nil
        self.sorting = ListsSorting.ascending(by: \List.title)
        self.isIncluded = nil
        self.includeItemsCount = false
        return self
    }

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

    func build(on worker: EventLoop) throws -> EventLoopFuture<[ListRepresentation]> {
        guard let user = user else {
            throw ListRepresentationsBuilderError.missingRequiredUser
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
                    var representation = ListRepresentation(list)
                    if self.includeItemsCount {
                        return try self.itemRepository
                            .count(on: list)
                            .map { count in
                                representation.itemsCount = count
                                return representation
                            }
                    }
                    else {
                        return worker.makeSucceededFuture(representation)
                    }
                }
                .flatten(on: worker)
            }
    }

}

enum ListRepresentationsBuilderError: Error {
    case missingRequiredUser
}
