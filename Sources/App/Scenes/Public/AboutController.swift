import Vapor

final class AboutController: Controller, RouteCollection {

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try request.authenticated(User.self)

        let context = AboutPageContext(for: user)
        return try renderView("Public/About", with: context, on: request)
    }

    func boot(router: Router) throws {
        router.get("about", use: AboutController.renderView)
    }

}
