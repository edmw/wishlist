import Vapor

final class PrivacyPolicyController: Controller, RouteCollection {

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try request.authenticated(User.self)

        let context = PrivacyPolicyPageContext(for: user)
        return try Controller.renderLocalizedView(
            "Public/PrivacyPolicy",
            with: context,
            on: request
        )
    }

    func boot(router: Router) throws {
        router.get("privacy-policy", use: self.renderView)
    }

}
