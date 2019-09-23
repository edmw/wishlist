import Vapor

final class SettingsNotificationsController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    static func testNotifications(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        let title = "🎁 Notification Test" // FIXME
        let text = "Notification Test"

        var notifications: [Notification] = []

        if user.settings.notificationServices.pushoverEnabled {
            let key = user.settings.notificationServices.pushoverKey
            notifications.append(
                .pushover(message: text, title: title, users: [key])
            )
        }

        return try request.make(NotificationService.self)
            .emit(notifications, on: request)
            .flatMap { results in
                let context = SettingsNotificationsPageContext(results, for: user)
                return try renderView("User/SettingsNotifications", with: context, on: request)
            }
    }

    // MARK: - CRUD

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
        return try renderView("User/SettingsForm", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
                switch method {
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {
    }

}
