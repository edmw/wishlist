import Vapor

final class SettingsNotificationsController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    static func testNotifications(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        return try SettingsNotificationsNotification(for: user).send(on: request)
            .flatMap { sendResult -> Future<View> in
                let context = SettingsNotificationsPageContext(sendResult, for: user)
                return try renderView("User/SettingsNotifications", with: context, on: request)
            }
            .catchFlatMap(DispatchingError.self) { _ -> Future<View> in
                let context = SettingsNotificationsPageContext(for: user)
                return try renderView("User/SettingsNotifications", with: context, on: request)
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
