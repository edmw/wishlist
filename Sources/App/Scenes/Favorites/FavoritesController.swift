import Domain

import Vapor
import Fluent

final class FavoritesController: AuthenticatableController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    let userFavoritesActor: UserFavoritesActor

    init(_ userFavoritesActor: UserFavoritesActor) {
        self.userFavoritesActor = userFavoritesActor
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        let sorting = getSorting(on: request) ?? .ascending(by: \List.title)

        return try userFavoritesActor
            .getFavorites(
                .specification(userBy: userid, with: sorting),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try FavoritesPageContext.builder
                    .forUser(result.user)
                    .withFavorites(result.favorites)
                    .build()
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
