import Vapor

final class LegalNoticeController: Controller, RouteCollection {

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try request.authenticated(User.self)

        let context = LegalNoticePageContext(for: user)
        return try Controller.renderView("Public/LegalNotice", with: context, on: request)
    }

    func boot(router: Router) throws {
        router.get("legal-notice", use: self.renderView)
    }

}
