import Domain

import Vapor

final class InvitationsController: AuthenticatableController,
    RouteCollection
{
    let userInvitationsActor: UserInvitationsActor

    init(_ userInvitationsActor: UserInvitationsActor) {
        self.userInvitationsActor = userInvitationsActor
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try userInvitationsActor
            .getInvitations(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .invitations(with: result), on: request)
            }
            .handleAuthorizationError(on: request)
    }

    // MARK: - Routing

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "invitations",
            use: self.renderView
        )
    }

}
