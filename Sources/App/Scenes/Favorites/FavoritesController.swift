import Vapor
import Fluent

final class FavoritesController: ProtectedController, SortingController, RouteCollection {
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
        return try request.make(FavoriteRepository.self)
            .favorites(for: user, sort: sorting)
            .flatMap { lists in
                return try lists.map { list in
                    var context = ListContext(for: list)
                    let owner = list.user.get(on: request)
                    let itemsCount = try request.make(ItemRepository.self).count(on: list)
                    return flatMap(owner, itemsCount) { owner, itemsCount in
                        context.ownerName = owner.displayName
                        context.itemsCount = itemsCount
                        return request.future(context)
                    }
                }
                .flatten(on: request)
            }
    }

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        return try FavoritesController.buildContexts(for: user, on: request)
            .flatMap {
                let context = ListsPageContext(for: user, with: $0)
                return try renderView("User/Favorites", with: context, on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "favorites",
            use: FavoritesController.renderView
        )
    }

}
