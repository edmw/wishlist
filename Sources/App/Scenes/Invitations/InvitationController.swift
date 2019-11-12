import Vapor
import Fluent

final class InvitationController: ProtectedController,
    InvitationParameterAcceptor,
    RouteCollection
{

    let invitationRepository: InvitationRepository

    init(_ invitationRepository: InvitationRepository) {
        self.invitationRepository = invitationRepository
    }

    private func authorizeUser<R>(
        on request: Request,
        _ render: @escaping (User) throws -> EventLoopFuture<R>
    ) throws -> EventLoopFuture<R> {
        let user = try requireAuthenticatedUser(on: request)

        guard user.confidant else {
            throw Abort(.unauthorized)
        }

        return try render(user)
    }

    private func authorizeInvitation(
        on request: Request,
        with user: User,
        _ function: @escaping (Invitation) throws -> EventLoopFuture<Response>
    ) throws -> EventLoopFuture<Response> {

        // get invitation from request
        return try self.requireInvitation(on: request)
            .flatMap { invitation in

                // check if the found invitation belongs to the given user
                guard invitation.userID == user.id else {
                    throw Abort(.notFound)
                }

                // execute the given function after authorization
                return try function(invitation)
            }
    }

    // MARK: - VIEWS

    /// Renders a form view for creating an invitation.
    /// This is only accessible for an authenticated user.
    private func renderCreateView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try self.authorizeUser(on: request) { user in
            let context = try InvitationPageContextBuilder().forUser(user).build()
            return try Controller.renderView("User/Invitation", with: context, on: request)
        }
    }

    /// Renders a view to confirm the deletion of an invitation.
    /// This is only accessible for an authenticated user.
    private func renderRevokeView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try self.authorizeUser(on: request) { user in
            return try self.requireInvitation(on: request)
                .flatMap { invitation in
                    let context = try InvitationPageContextBuilder()
                        .forUser(user)
                        .forInvitation(invitation)
                        .build()
                    return try Controller.renderView(
                        "User/InvitationRevocation",
                        with: context,
                        on: request
                    )
                }
        }
    }

    // MARK: - CRUD

    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        return try self.authorizeUser(on: request) { user in
            return try self.save(from: request, for: user)
                .caseSuccess { outcome in
                    let result = try request.future(outcome.invitation)
                        .emitEvent("created for \(user)", on: request)
                        .logMessage("created for \(user)", on: request)
                    if outcome.thenSendMail {
                        return result
                            .sendInvitation(on: request)
                            .transform(to: self.success(for: user, on: request))
                    }
                    else {
                        return result.transform(to: self.success(for: user, on: request))
                    }
                }
            .caseFailure { context in try self.failure(on: request, with: context) }
        }
    }

    private func patch(on request: Request) throws -> EventLoopFuture<Response> {
        return try self.authorizeUser(on: request) { user in
            return try self.authorizeInvitation(on: request, with: user) { invitation in
                struct Patch: Decodable {
                    let key: String
                    let value: String
                }
                return try request.content.decode(Patch.self)
                    .flatMap { patch in
                        switch patch.key {
                        case "status":
                            guard let status = Invitation.Status(string: patch.value) else {
                                throw Abort(.badRequest)
                            }
                            return try invitation
                                .update(status: status, in: self.invitationRepository)
                                .logMessage("updated for \(user)", on: request)
                                .transform(to: self.success(for: user, on: request))
                        default:
                            throw Abort(.badRequest)
                        }
                    }
            }
        }
    }

    // MARK: - ACTIONS

    /// Sends an invitation.
    /// This is only accessible for an authenticated user.
    private func sendInvitation(on request: Request) throws
        -> EventLoopFuture<Response>
    {
        return try self.authorizeUser(on: request) { user in
            return try self.requireInvitation(on: request, status: .open)
                .sendInvitation(on: request)
                .transform(to: self.success(for: user, on: request))
        }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for user: User, on request: Request) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
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
        // to add real REST support, check the accept header for json and output a json response
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

// MARK: Future

extension EventLoopFuture where Expectation == Invitation {

    /// Sends an invitation mail and updates sent date of invitation on succes.
    func sendInvitation(on request: Request) -> EventLoopFuture<(Invitation, SendMessageResult)> {
        return self.flatMap { invitation in
            return try InvitationMail(invitation).send(on: request).flatMap { sendResult in
                if sendResult.success {
                    invitation.sentAt = Date()
                    return invitation
                        .save(on: request)
                        .transform(to: (invitation, sendResult))
                }
                return request.future((invitation, sendResult))
            }
        }
    }

}
