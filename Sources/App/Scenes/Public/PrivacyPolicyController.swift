import Vapor

final class PrivacyPolicyController: Controller, RouteCollection {

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try request.authenticated(User.self)

        let context = PrivacyPolicyPageContext(for: user)
        return try renderLocalizedView("Public/PrivacyPolicy", with: context, on: request)
    }

    func boot(router: Router) throws {
        router.get("privacy-policy", use: PrivacyPolicyController.renderView)
    }

}
