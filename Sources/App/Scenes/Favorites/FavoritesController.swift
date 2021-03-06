import Domain

import Vapor

// MARK: Controller Parameters

// messages to display
extension ControllerParameterMessageValue {

    // Wish already reserved (this is possible because of a potential race condition)
    static let userNotificationsDisabledForFavorites = ControllerParameterMessageValue("UND-F")

}

// MARK: FavoritesController

final class FavoritesController: AuthenticatableController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    let userFavoritesActor: UserFavoritesActor

    init(_ userFavoritesActor: UserFavoritesActor) {
        self.userFavoritesActor = userFavoritesActor
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        let sorting = getSorting(on: request)
        return try userFavoritesActor
            .getFavorites(
                .specification(userBy: userid, with: sorting),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .favorites(with: result), on: request)
            }
    }

    // MARK: - Routing

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "favorites",
            use: self.renderView
        )
    }

}
