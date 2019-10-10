import Vapor
import Fluent

final class InvitationController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    private static func allowView(
        on request: Request,
        _ render: @escaping (User) throws -> Future<View>
    ) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        guard user.confidant else {
            throw Abort(.unauthorized)
        }

        return try render(user)
    }

    /// Renders a form view for creating an invitation.
    /// This is only accessible for an authenticated user.
    private static func renderCreateView(on request: Request) throws
        -> Future<View>
    {
        return try allowView(on: request) { (user) throws in
            let context = InvitationPageContext(for: user)
            return try renderView("User/Invitation", with: context, on: request)
        }
    }

    /// Renders a view to confirm the deletion of an invitation.
    /// This is only accessible for an authenticated user.
    private static func renderRevokeView(on request: Request) throws
        -> Future<View>
    {
        return try allowView(on: request) { (user) throws in
            return try requireInvitation(on: request)
                .flatMap { invitation in
                    let context = InvitationPageContext(
                        for: user,
                        with: invitation
                    )
                    return try renderView("User/InvitationRevocation", with: context, on: request)
                }
        }
    }

    // MARK: - CRUD

    private static func authorizeUser(
        on request: Request,
        _ function: @escaping (User) throws -> Future<Response>
    ) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        guard user.confidant else {
            throw Abort(.unauthorized)
        }

        return try function(user)
    }

    private static func authorizeInvitation(
        on request: Request,
        with user: User,
        _ function: @escaping (Invitation) throws -> Future<Response>
    ) throws -> Future<Response> {

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

    private static func create(on request: Request) throws -> Future<Response> {
        return try authorizeUser(on: request) { (user) throws in
            return try save(from: request, for: user)
        }
    }

    private static func patch(on request: Request) throws -> Future<Response> {
        return try authorizeUser(on: request) { (user) throws in
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
                                .transform(to: success(for: user, on: request))
                        default:
                            throw Abort(.badRequest)
                        }
                    }
            }
        }
    }

    /// Saves an invitation for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new
    /// invitation and creates a new invitation.
    ///
    /// This function handles thrown `EntityError`s by rendering the form page again while adding
    /// the corresponding error flags to the page context.
    private static func save(
        from request: Request,
        for user: User
    ) throws
        -> Future<Response>
    {
        return try request.content
            .decode(InvitationPageFormData.self)
            .flatMap { formdata in
                var context = InvitationPageContext(for: user, from: formdata)

                return request.future()
                    .flatMap {
                        return try save(
                            from: formdata,
                            for: user,
                            on: request
                        )
                    }
                    .catchFlatMap(EntityError<Invitation>.self) { error in
                        switch error {
                        case .validationFailed(let properties, _):
                            context.form.invalidEmail = properties.contains(\Invitation.email)
                        default:
                            throw error
                        }
                        return try failure(on: request, with: context)
                    }
            }
    }

    /// Saves an invitation for the specified user from the given form data.
    /// Validates the data, checks the constraints required for a new invitation and creates
    /// a new invitation.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private static func save(
        from formdata: InvitationPageFormData,
        for user: User,
        on request: Request
    ) throws
        -> Future<Response>
    {
        let invitationRepository = try request.make(InvitationRepository.self)

        return try InvitationData(from: formdata)
            .validate(for: user, using: invitationRepository)
            .flatMap { data in
                let entity: Invitation
                // create invitation
                entity = try Invitation(for: user, from: data)

                return try invitationRepository
                    .save(invitation: entity)
                    .emitEvent("created for \(user)", on: request)
                    .transform(to: success(for: user, on: request))
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for user: User, on request: Request) -> Future<Response> {
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
    ) throws -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/Invitation", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
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
    }

    // MARK: -

    /// Returns the invitation specified by the invitation id given in the request’s route.
    /// Asumes that the invitation id is the next routing parameter!
    static func requireInvitation(on request: Request) throws -> Future<Invitation> {
        let invitationID = try request.parameters.next(ID.self)
        return try request.make(InvitationRepository.self)
            .find(by: invitationID.uuid)
            .unwrap(or: Abort(.noContent))
    }

    /// Returns the item specified by an item id given in the request’s body or query.
    static func findItem(in list: List, from request: Request) throws -> Future<Item> {
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
