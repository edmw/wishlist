import Vapor

final class SettingsController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    /// Renders a form view for creating or updating the settings.
    /// This is only accessible for an authenticated user.
    private static func renderFormView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        let data = SettingsPageFormData(from: user)
        let context = SettingsPageContext(for: user, from: data)
        return try renderView("User/Settings", with: context, on: request)
    }

    // MARK: - CRUD

    private static func update(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
    }

    /// Saves settings for the specified user from the request’s data.
    /// Validates the data contained in the request and updates the user.
    private static func save(
        from request: Request,
        for user: User
    ) throws
        -> Future<Response>
    {
        return try request.content
            .decode(SettingsPageFormData.self)
            .flatMap { formdata in
                var context = SettingsPageContext(for: user, from: formdata)

                return request.future()
                    .flatMap {
                        return try save(from: formdata, for: user, on: request)
                    }
                    .catchFlatMap(ValidationError.self) { error in
                        // WORKAROUND: See https://github.com/vapor/validation/issues/26
                        // This is a hack which parses the textual reason for an validation error.
                        let reason = error.reason
                        if reason.contains("'pushoverkey' missing") {
                            context.form.missingPushoverKey = true
                        }
                        else {
                            context.form.invalidPushoverKey =
                                reason.contains("'notifications.pushoverKey'")
                        }
                        return try failure(on: request, with: context)
                    }
            }
    }

    /// Saves settings from the given form data.
    /// Validates the data, checks the constraints required for an updated user and updates an
    /// existing user.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private static func save(
        from formdata: SettingsPageFormData,
        for user: User,
        on request: Request
    ) throws
        -> Future<Response>
    {
        let userRepository = try request.make(UserRepository.self)

        var settings = user.settings
        settings.update(from: formdata)
        try settings.validate()
        user.settings = settings
        return userRepository
            .save(user: user)
            .transform(to: success(for: user, on: request))
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
                result: redirect(for: user, to: "", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private static func failure(
        on request: Request,
        with context: SettingsPageContext
    ) throws -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/Settings", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
                switch method {
                case .PUT:
                    return try update(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // settings handling

        router.get("user", ID.parameter, "settings", "edit",
            use: SettingsController.renderFormView
        )
        router.post("user", ID.parameter, "settings",
            use: SettingsController.dispatch
        )

        // notifications handling
        router.get("user", ID.parameter, "settings", "notifications", "test")
            { request -> Future<View> in
                guard try request.makeFeatures().userNotifications.enabled else {
                    throw Abort(.badRequest)
                }
                return try SettingsNotificationsController.testNotifications(on: request)
        }

    }

}
