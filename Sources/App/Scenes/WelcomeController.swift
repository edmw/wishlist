import Domain

import Vapor

// MARK: Controller Parameters

extension ControllerParameter {

    // display a welcome message on first login
    static func welcome() -> ControllerParameter {
        return ControllerParameter(key: "welcome", nil)
    }

}

// MARK: - WelcomeController

/// Controller for displaying the welcome page.
final class WelcomeController: AuthenticatableController, RouteCollection {

    let userWelcomeActor: UserWelcomeActor

    init(_ userWelcomeActor: UserWelcomeActor) {
        self.userWelcomeActor = userWelcomeActor
    }

    func renderView(on request: Request) throws -> EventLoopFuture<View> {
        guard let userid = try authenticatedUserID(on: request) else {
            return try WelcomeController.render(page: .welcome(), on: request)
        }
        return try userWelcomeActor
            .getListsAndFavorites(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .welcome(with: result), on: request)
            }
    }

    func boot(router: Router) throws {
        router.get("/", use: self.renderView)
    }

}
