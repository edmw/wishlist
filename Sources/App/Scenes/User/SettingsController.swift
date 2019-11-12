import Vapor

final class SettingsController: ProtectedController, RouteCollection {

    let userRepository: UserRepository

    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    // MARK: - VIEWS

    /// Renders a form view for creating or updating the settings.
    /// This is only accessible for an authenticated user.
    private func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        let data = SettingsPageFormData(from: user)
        let context = try SettingsPageContextBuilder()
            .forUser(user)
            .withFormData(data)
            .build()
        return try Controller.renderView("User/Settings", with: context, on: request)
    }

    func testNotifications(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        return try SettingsNotificationsNotification(for: user).send(on: request)
            .flatMap { sendResult -> EventLoopFuture<View> in
                let context = SettingsNotificationsPageContext(sendResult, for: user)
                return try Controller.renderView(
                    "User/SettingsNotificationsSent",
                    with: context,
                    on: request
                )
            }
            .catchFlatMap(DispatchingError.self) { _ -> EventLoopFuture<View> in
                let context = SettingsNotificationsPageContext(for: user)
                return try Controller.renderView(
                    "User/SettingsNotificationsSent",
                    with: context,
                    on: request
                )
            }
    }

    // MARK: - CRUD

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
            .caseSuccess { self.success(for: user, on: request) }
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

        // notifications handling
        router.get("user", ID.parameter, "settings", "notifications", "test")
            { request -> EventLoopFuture<View> in
                return try self.testNotifications(on: request)
        }

    }

}
