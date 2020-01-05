import Domain

import Vapor

final class PrivacyPolicyController: AuthenticatableController, RouteCollection {

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
                let context = PrivacyPolicyPageContext(for: result.user)
                return try Controller.renderLocalizedView(
                    "Public/PrivacyPolicy",
                    with: context,
                    on: request
                )
            }
    }

    func boot(router: Router) throws {
        router.get("privacy-policy", use: self.renderView)
    }

}
