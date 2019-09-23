import Vapor
import Fluent

final class ListsController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    static func buildContexts(for user: User, on request: Request) throws
        -> Future<[ListContext]>
    {
        let sorting = getSorting(on: request) ?? .ascending(by: \List.title)
        // First, we query all lists of the user.
        // Next, we map every list to a future of a context.
        // Meanwhile, we query the number of items for every list and add it to each context.
        // Then, we flatten the array of context futures to a future of an array of contexts.
        // Now, we map the future of an array of contexts to the actual array of contexts.
        // (better would be: use a join on the database)
        return try request.make(ListRepository.self)
            .all(for: user, sort: sorting)
            .flatMap { lists in
                return try lists.map { list in
                    var context = ListContext(for: list)
                    return try request.make(ItemRepository.self)
                        .count(on: list)
                        .map { count in
                            context.itemsCount = count
                            return context
                        }
                }
                .flatten(on: request)
            }
    }

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        return try ListsController.buildContexts(for: user, on: request)
            .flatMap {
                let context = ListsPageContext(for: user, with: $0)
                return try renderView("User/Lists", with: context, on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "lists",
            use: ListsController.renderView
        )
    }

}
