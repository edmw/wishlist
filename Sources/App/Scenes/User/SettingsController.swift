import Domain

import Vapor

final class SettingsController: AuthenticatableController, RouteCollection {

    let userSettingsActor: UserSettingsActor

    init(_ userSettingsActor: UserSettingsActor) {
        self.userSettingsActor = userSettingsActor
    }

    // MARK: - VIEWS

    /// Renders a form view for creating or updating the settings.
    /// This is only accessible for an authenticated user.
    private func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let userid = try requireAuthenticatedUserID(on: request)

        return try userSettingsActor
            .requestSettingsEditing(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let data = SettingsPageFormData(from: result.user)
                let context = try SettingsPageContextBuilder()
                    .forUser(result.user)
                    .withFormData(data)
                    .build()
                return try Controller.renderView("User/Settings", with: context, on: request)
            }
    }

    // MARK: - CRUD

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try save(from: request, for: userid)
            .caseSuccess { user in self.success(for: user, on: request) }
            .caseFailure { context in try self.failure(on: request, with: context) }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for user: UserRepresentation, on request: Request)
        -> EventLoopFuture<Response>
    {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(for: user.id, to: "", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        on request: Request,
        with context: SettingsPageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.renderView("User/Settings", with: context, on: request)
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

        // settings handling

        router.get("user", ID.parameter, "settings", "edit",
            use: self.renderFormView
        )
        router.post("user", ID.parameter, "settings",
            use: self.dispatch
        )

    }

}
