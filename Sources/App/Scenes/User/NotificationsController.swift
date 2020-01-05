import Domain

import Vapor

final class NotificationsController: AuthenticatableController, RouteCollection {

    let userNotificationsActor: UserNotificationsActor

    init(_ userNotificationsActor: UserNotificationsActor) {
        self.userNotificationsActor = userNotificationsActor
    }

    // MARK: - ACTIONS

    /// Not implemented yet: REST response
    func testNotifications(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let userid = try requireAuthenticatedUserID(on: request)

        return try userNotificationsActor
            .testNotifications(
                .specification(userBy: userid),
                .boundaries(
                    worker: request.eventLoop,
                    notificationSending: VaporNotificationSendingProvider(on: request)
                )
            )
            .flatMap { result in
                let context = NotificationsPageContext(result, for: result.user)
                return try Controller.renderView(
                    "User/SettingsNotificationsSent",
                    with: context,
                    on: request
                )
            }
    }

    // MARK: -

    func boot(router: Router) throws {

        // notifications handling

        router.get("user", ID.parameter, "settings", "notifications", "test",
            use: self.testNotifications
        )

    }

}
