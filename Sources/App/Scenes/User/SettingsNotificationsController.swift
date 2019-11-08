import Vapor

final class SettingsNotificationsController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    static func testNotifications(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        return try SettingsNotificationsNotification(for: user).send(on: request)
            .flatMap { sendResult -> EventLoopFuture<View> in
                let context = SettingsNotificationsPageContext(sendResult, for: user)
                return try renderView("User/SettingsNotificationsSent", with: context, on: request)
            }
            .catchFlatMap(DispatchingError.self) { _ -> EventLoopFuture<View> in
                let context = SettingsNotificationsPageContext(for: user)
                return try renderView("User/SettingsNotificationsSent", with: context, on: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {
    }

}
