import Vapor

final class ProfileController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let invitations = try InvitationsController.buildContexts(for: user, on: request)

        return invitations.flatMap { invitations in
            let context = try ProfilePageContextBuilder()
                .forUser(user)
                .withInvitations(invitations)
                .build()
            return try renderView("User/Profile", with: context, on: request)
        }
    }

    /// Renders a form view for creating or updating the profile.
    /// This is only accessible for an authenticated user.
    private static func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        let data = ProfilePageFormData(from: user)
        let context = try ProfilePageContextBuilder()
            .forUser(user)
            .withFormData(data)
            .build()
        return try renderView("User/ProfileForm", with: context, on: request)
    }

    // MARK: - CRUD

    private static func update(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
            .flatMap { result in
                switch result {
                case let .success(user):
                    return request.future(user)
                        .logMessage("updated", on: request)
                        .transform(to: success(for: user, on: request))
                case .failure(let context):
                    return try failure(on: request, with: context)
                }
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
                result: redirect(for: user, to: "", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private static func failure(
        on request: Request,
        with context: ProfilePageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/ProfileForm", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try update(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // profile displaying

        router.get("user", ID.parameter, use: ProfileController.renderView)

        // profile handling

        router.get("user", ID.parameter, "edit",
            use: ProfileController.renderFormView
        )
        router.post("user", ID.parameter,
            use: ProfileController.dispatch
        )
    }

}
