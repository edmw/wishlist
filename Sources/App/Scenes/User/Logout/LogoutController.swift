import Domain

import Vapor

final class LogoutController: Controller, RouteCollection {

    func boot(router: Router) throws {
        router.get("user/logout") { request -> EventLoopFuture<Response> in
            try request.clearSessionFromIdentification()
            try request.unauthenticateSession(UserID.self)
            try request.destroySession()
            return Controller.redirect(to: "/", on: request)
        }
    }

}
