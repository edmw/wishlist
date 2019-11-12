import Vapor

final class LogoutController: Controller, RouteCollection {

    func boot(router: Router) throws {
        router.get("user/logout") { request -> EventLoopFuture<Response> in
            try request.unauthenticateSession(User.self)
            try request.clearIdentification()
            try request.destroySession()
            return Controller.redirect(to: "/", on: request)
        }
    }

}
