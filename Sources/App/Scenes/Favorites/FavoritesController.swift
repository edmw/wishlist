import Vapor
import Fluent

final class FavoritesController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let favoriteContextsBuilder = FavoriteContextsBuilder()
            .forUser(user)
            .withSorting(getSorting(on: request) ?? .ascending(by: \List.title))
            .includeItemsCount(true)
        return try favoriteContextsBuilder.build(on: request)
            .flatMap {
                let context = FavoritesPageContext(for: user, with: $0)
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
