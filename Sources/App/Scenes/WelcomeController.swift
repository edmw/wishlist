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

        let lists = try ListsController.buildContexts(for: user, on: request)
        let favorites = try FavoritesController.buildContexts(for: user, on: request)
        return flatMap(lists, favorites) { lists, favorites in
            let context = WelcomePageContext(for: user, lists: lists, favorites: favorites)
            return try renderView("User/Welcome", with: context, on: request)
        }
    }

    func boot(router: Router) throws {
        router.get("/", use: WelcomeController.renderView)
    }

}
