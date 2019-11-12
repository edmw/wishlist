import Vapor
import Fluent

final class FavoritesController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    let favoriteRepository: FavoriteRepository
    let itemRepository: ItemRepository

    init(_ favoriteRepository: FavoriteRepository, _ itemRepository: ItemRepository) {
        self.favoriteRepository = favoriteRepository
        self.itemRepository = itemRepository
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let sorting = getSorting(on: request) ?? .ascending(by: \List.title)
        let favoriteContextsBuilder = FavoriteContextsBuilder(favoriteRepository, itemRepository)
            .forUser(user)
            .withSorting(sorting)
            .includeItemsCount(true)
        return try favoriteContextsBuilder.build(on: request)
            .flatMap {
                let context = FavoritesPageContext(for: user, with: $0)
                return try Controller.renderView("User/Favorites", with: context, on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "favorites",
            use: self.renderView
        )
    }

}
