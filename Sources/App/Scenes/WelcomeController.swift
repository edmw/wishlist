import Vapor

// MARK: - Controller Parameters

extension ControllerParameter {
    // display a welcome message on first login
    static func welcome() -> ControllerParameter {
        return ControllerParameter(key: "welcome", nil)
    }
}

// MARK: - Controller

/// Controller for displaying the welcome page.
final class WelcomeController: Controller, RouteCollection {

    static func renderView(on request: Request) throws -> Future<View> {
        guard let user = try request.authenticated(User.self) else {
            return try WelcomeController.renderView("Public/Welcome", on: request)
        }

        let listContextsBuilder = ListContextsBuilder().forUser(user).countItems(true)
        let listContexts = try listContextsBuilder.build(on: request)
        let favoriteContextsBuilder = FavoriteContextsBuilder().forUser(user).countItems(true)
        let favoriteContexts = try favoriteContextsBuilder.build(on: request)
        return flatMap(listContexts, favoriteContexts) { listContexts, favoriteContexts in
            let context = WelcomePageContext(
                for: user,
                lists: listContexts,
                favorites: favoriteContexts
            )
            return try renderView("User/Welcome", with: context, on: request)
        }
    }

    func boot(router: Router) throws {
        router.get("/", use: WelcomeController.renderView)
    }

}
