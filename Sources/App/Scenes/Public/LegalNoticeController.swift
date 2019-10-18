import Vapor

final class LegalNoticeController: Controller, RouteCollection {

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try request.authenticated(User.self)

        let context = LegalNoticePageContext(for: user)
        return try renderView("Public/LegalNotice", with: context, on: request)
    }

    func boot(router: Router) throws {
        router.get("legal-notice", use: LegalNoticeController.renderView)
    }

}
