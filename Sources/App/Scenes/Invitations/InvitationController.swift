import Domain

import Vapor
import Fluent

final class InvitationController: AuthenticatableController,
    InvitationParameterAcceptor,
    RouteCollection
{
    let userInvitationsActor: UserInvitationsActor

    init(_ userInvitationsActor: UserInvitationsActor) {
        self.userInvitationsActor = userInvitationsActor
    }

    // MARK: - VIEWS

    /// Renders a form view for creating an invitation.
    /// This is only accessible for an authenticated and authorized user.
    private func renderCreateView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try userInvitationsActor
            .requestInvitationCreation(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try InvitationPageContext.builder
                    .forUser(result.user)
                    .build()
                return try Controller.renderView("User/Invitation", with: context, on: request)
            }
    }

    /// Renders a view to confirm the deletion of an invitation.
    /// This is only accessible for an authenticated and authorized user.
    private func renderRevokeView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let invitationid = try requireInvitationID(on: request)

        return try userInvitationsActor
            .requestInvitationRevocation(
                .specification(userBy: userid, invitationBy: invitationid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try InvitationPageContext.builder
                    .forUser(result.user)
                    .withInvitation(result.invitation)
                    .build()
                return try Controller.renderView(
                    "User/InvitationRevocation",
                    with: context,
                    on: request
                )
                .encode(for: request)
            }
            .catchMap(UserFavoritesActor.self) { _ in
                // Tries to redirect back to the start page.
                return Controller.redirect(to: "/", on: request)
            }
    }

    // MARK: - CRUD

    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try save(from: request, for: userid)
            .caseSuccess { result in self.success(for: result.user, on: request) }
            .caseFailure { context in try self.failure(on: request, with: context) }
    }

    private struct Patch: Decodable {
        let key: String
        let value: String
    }

    private func patch(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let invitationid = try requireInvitationID(on: request)

        let userInvitationsActor = self.userInvitationsActor
        return try request.content.decode(Patch.self)
            .flatMap { patch in
                switch patch.key {
                case "status":
                    guard let status = Invitation.Status(string: patch.value), status == .revoked
                        else {
                            throw Abort(.badRequest)
                        }
                    return try userInvitationsActor
                        .revokeInvitation(
                            .specification(userBy: userid, invitationBy: invitationid),
                            .boundaries(worker: request.eventLoop)
                        )
                        .flatMap { result in self.success(for: result.user, on: request) }
                default:
                    throw Abort(.badRequest)
                }
            }
    }

    // MARK: - ACTIONS

    /// Sends an invitation.
    /// This is only accessible for an authenticated and authorized user.
    private func sendInvitation(on request: Request) throws
        -> EventLoopFuture<Response>
    {
        let userid = try requireAuthenticatedUserID(on: request)
        let invitationid = try requireInvitationID(on: request)

        return try userInvitationsActor
            .sendInvitationEmail(
                .specification(userBy: userid, invitation: invitationid),
                .boundaries(
                    worker: request.eventLoop,
                    emailSending: VaporEmailSendingProvider(on: request)
                )
            )
            .flatMap { result in
                return self.success(for: result.user, on: request)
            }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(
        for user: UserRepresentation,
        on request: Request
    ) -> EventLoopFuture<Response> {
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: "/", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        on request: Request,
        with context: InvitationPageContext
    ) throws -> EventLoopFuture<Response> {
        return try Controller.renderView("User/Invitation", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: - Routing

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PATCH:
                    return try self.patch(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // invitation creation

        router.get("user", ID.parameter, "invitations", "create",
            use: self.renderCreateView
        )
        router.post("user", ID.parameter, "invitations",
            use: self.create
        )

        // reservation handling

        router.get(
            "user", ID.parameter, "invitation", ID.parameter, "revoke",
            use: self.renderRevokeView
        )
        router.post(
            "user", ID.parameter, "invitation", ID.parameter,
            use: self.dispatch
        )
        // action
        router.post(
            "user", ID.parameter, "invitation", ID.parameter, "send",
            use: self.sendInvitation
        )
    }

}
