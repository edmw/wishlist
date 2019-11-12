import Vapor

final class ProfileController: ProtectedController,
    RouteCollection
{

    let userRepository: UserRepository
    let invitationRepository: InvitationRepository

    init(_ userRepository: UserRepository, _ invitationRepository: InvitationRepository) {
        self.userRepository = userRepository
        self.invitationRepository = invitationRepository
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let invitationContextsBuilder = InvitationContextsBuilder(self.invitationRepository)
            .forUser(user)
        return try invitationContextsBuilder.build(on: request)
            .flatMap { invitationContexts in
                let context = try ProfilePageContextBuilder()
                    .forUser(user)
                    .withInvitationContexts(invitationContexts)
                    .build()
                return try Controller.renderView("User/Profile", with: context, on: request)
            }
    }

    /// Renders a form view for creating or updating the profile.
    /// This is only accessible for an authenticated user.
    private func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        let data = ProfilePageFormData(from: user)
        let context = try ProfilePageContextBuilder()
            .forUser(user)
            .withFormData(data)
            .build()
        return try Controller.renderView("User/ProfileForm", with: context, on: request)
    }

    // MARK: - CRUD

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
            .caseSuccess { user in
                return request.future(user)
                    .logMessage("updated", on: request)
                    .transform(to: self.success(for: user, on: request))
            }
        .caseFailure { context in try self.failure(on: request, with: context) }
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
                result: Controller.redirect(for: user, to: "", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        on request: Request,
        with context: ProfilePageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.renderView("User/ProfileForm", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try self.update(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // profile displaying

        router.get("user", ID.parameter, use: self.renderView)

        // profile handling

        router.get("user", ID.parameter, "edit",
            use: self.renderFormView
        )
        router.post("user", ID.parameter,
            use: self.dispatch
        )
    }

}
