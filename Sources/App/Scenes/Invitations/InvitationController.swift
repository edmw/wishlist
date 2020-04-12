import Domain

import Vapor

// MARK: InvitationController

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
                try Controller.render(page: .invitationCreation(with: result), on: request)
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
                try Controller.render(page: .invitationRevocation(with: result), on: request)
                    .encode(for: request)
            }
            .catchMap(UserFavoritesActor.self) { _ in
                // Tries to redirect back to the start page.
                Controller.redirect(to: "/", on: request)
            }
    }

    // MARK: - CRUD

    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try save(from: request, for: userid)
            .caseSuccess { user in
                self.success(for: user, on: request)
            }
            .caseFailure { user, context in
                try self.failure(for: user, with: context, on: request)
            }
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
                        .flatMap { result in
                            self.success(for: result.user, on: request)
                        }
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
                self.success(for: result.user, on: request)
            }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(
        for user: UserRepresentation,
        on request: Request
    ) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        let location = request.query.getLocator(is: .local)?.locationString ?? "/"
        return request.eventLoop.newSucceededFuture(
            result: Controller.redirect(to: location, on: request)
        )
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        for user: UserRepresentation,
        with editingContext: InvitationEditingContext,
        on request: Request
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.render(
            page: .invitationCreation(with: user, editingContext: editingContext),
            on: request
        )
        .encode(for: request)
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
