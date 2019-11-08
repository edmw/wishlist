import Vapor
import Fluent

final class InvitationController: ProtectedController, RouteCollection {

    private static func authorizeUser<R>(
        on request: Request,
        _ render: @escaping (User) throws -> EventLoopFuture<R>
    ) throws -> EventLoopFuture<R> {
        let user = try requireAuthenticatedUser(on: request)

        guard user.confidant else {
            throw Abort(.unauthorized)
        }

        return try render(user)
    }

    private static func authorizeInvitation(
        on request: Request,
        with user: User,
        _ function: @escaping (Invitation) throws -> EventLoopFuture<Response>
    ) throws -> EventLoopFuture<Response> {

        // get invitation from request
        return try requireInvitation(on: request)
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
    private static func renderCreateView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try authorizeUser(on: request) { user in
            let context = try InvitationPageContextBuilder().forUser(user).build()
            return try renderView("User/Invitation", with: context, on: request)
        }
    }

    /// Renders a view to confirm the deletion of an invitation.
    /// This is only accessible for an authenticated user.
    private static func renderRevokeView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try authorizeUser(on: request) { user in
            return try requireInvitation(on: request)
                .flatMap { invitation in
                    let context = try InvitationPageContextBuilder()
                        .forUser(user)
                        .forInvitation(invitation)
                        .build()
                    return try renderView("User/InvitationRevocation", with: context, on: request)
                }
        }
    }

    // MARK: - CRUD

    private static func create(on request: Request) throws -> EventLoopFuture<Response> {
        return try authorizeUser(on: request) { user in
            return try save(from: request, for: user)
                .caseSuccess { invitation, thenSendMail in
                    let result = try request.future(invitation)
                        .emitEvent("created for \(user)", on: request)
                        .logMessage("created for \(user)", on: request)
                    if thenSendMail {
                        return result
                            .sendInvitation(on: request)
                            .transform(to: success(for: user, on: request))
                    }
                    else {
                        return result.transform(to: success(for: user, on: request))
                    }
                }
                .caseFailure { context in
                    return try failure(on: request, with: context)
                }
        }
    }

    private static func patch(on request: Request) throws -> EventLoopFuture<Response> {
        return try authorizeUser(on: request) { user in
            return try authorizeInvitation(on: request, with: user) { invitation in
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
                                .update(status: status, in: request.make(InvitationRepository.self))
                                .logMessage("updated for \(user)", on: request)
                                .transform(to: success(for: user, on: request))
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
    private static func sendInvitation(on request: Request) throws
        -> EventLoopFuture<Response>
    {
        return try authorizeUser(on: request) { user in
            return try requireInvitation(on: request, status: .open).sendInvitation(on: request)
                .transform(to: success(for: user, on: request))
        }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for user: User, on request: Request) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: "/", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private static func failure(
        on request: Request,
        with context: InvitationPageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/Invitation", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PATCH:
                    return try patch(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // invitation creation

        router.get("user", ID.parameter, "invitations", "create",
            use: InvitationController.renderCreateView
        )
        router.post("user", ID.parameter, "invitations",
            use: InvitationController.create
        )

        // reservation handling

        router.get(
            "user", ID.parameter, "invitation", ID.parameter, "revoke",
            use: InvitationController.renderRevokeView
        )
        router.post(
            "user", ID.parameter, "invitation", ID.parameter,
            use: InvitationController.dispatch
        )
        // action
        router.post(
            "user", ID.parameter, "invitation", ID.parameter, "send",
            use: InvitationController.sendInvitation
        )
    }

    // MARK: -

    /// Returns the invitation specified by the invitation id given in the request’s route.
    /// Asumes that the invitation id is the next routing parameter!
    /// If a status is specified requires the invitation to conform to the given status,
    /// throws `.badRequest` if status’ differ.
    static func requireInvitation(on request: Request, status: Invitation.Status? = nil)
        throws -> EventLoopFuture<Invitation>
    {
        let invitationID = try request.parameters.next(ID.self)
        return try request.make(InvitationRepository.self)
            .find(by: invitationID.uuid)
            .unwrap(or: Abort(.noContent))
            .map { invitation in
                guard status == nil || invitation.status == status else {
                    throw Abort(.badRequest)
                }
                return invitation
            }
    }

    /// Returns the item specified by an item id given in the request’s body or query.
    static func findItem(in list: List, from request: Request) throws -> EventLoopFuture<Item> {
        return request.content[ID.self, at: "itemID"]
            .flatMap { itemID in
                guard let itemID = itemID ?? request.query[.itemID] else {
                    throw Abort(.notFound)
                }
                return try request.make(ItemRepository.self)
                    .find(by: itemID.uuid, in: list)
                    .unwrap(or: Abort(.noContent))
            }
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
