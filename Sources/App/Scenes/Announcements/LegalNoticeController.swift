import Domain

import Vapor

final class LegalNoticeController: AuthenticatableController, RouteCollection {

    let announcementsActor: AnnouncementsActor

    init(_ announcementsActor: AnnouncementsActor) {
        self.announcementsActor = announcementsActor
    }

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try authenticatedUserID(on: request)

        return try announcementsActor
            .presentPublicly(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .legalNotice(with: result), on: request)
            }
    }

    // MARK: - Routing

    func boot(router: Router) throws {
        router.get("legal-notice", use: self.renderView)
    }

}
