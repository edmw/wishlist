import Domain

import Vapor

// MARK: LogoutController

final class LogoutController: Controller, RouteCollection {

    // MARK: - Routing

    func boot(router: Router) throws {
        router.get("user/logout") { request -> EventLoopFuture<Response> in
            try request.clearSessionFromIdentification()
            try request.unauthenticateSession(UserID.self)
            try request.destroySession()
            return Controller.redirect(to: "/", on: request)
        }
    }

}
