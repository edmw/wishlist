import Foundation
import NIO

// MARK: TestNotifications

public struct TestNotifications: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
        public let notificationSending: NotificationSendingProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
    }

    // MARK: Result

    public struct Result: ActionResult, UserNotificationsResult {
        public let user: UserRepresentation
        public let sendingResults: [NotificationSendingResult]
        internal init(_ user: User, sendingResults: [NotificationSendingResult]) {
            self.user = user.representation
            self.sendingResults = sendingResults
        }
    }

}

// MARK: - Actor

extension DomainUserNotificationsActor {

    // MARK: testNotifications

    public func testNotifications(
        _ specification: TestNotifications.Specification,
        _ boundaries: TestNotifications.Boundaries
    ) throws -> EventLoopFuture<UserNotificationsResult> {
        let logging = self.logging
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserListsActorError.invalidUser)
            .flatMap { user in
                let userRepresentation = UserRepresentation(user)
                return try boundaries.notificationSending
                    .sendTestNotification(
                        for: userRepresentation,
                        using: UserNotificationService.channels(for: user)
                    )
                    .logMessage(.testNotifications(for: user), using: logging)
                    .map { sendingResults in
                        TestNotifications.Result(user, sendingResults: sendingResults)
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func testNotifications(for user: User)
        -> LoggingMessageRoot<[NotificationSendingResult]>
    {
        return .init({ results in
            LoggingMessage(
                label: "Test Notifications",
                subject: results,
                attributes: ["User": user]
            )
        })
    }

}
