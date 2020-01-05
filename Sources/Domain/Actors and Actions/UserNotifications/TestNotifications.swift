import Foundation
import NIO

// MARK: TestNotifications

public struct TestNotifications: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public let notificationSending: NotificationSendingProvider
        public static func boundaries(
            worker: EventLoop,
            notificationSending: NotificationSendingProvider
        ) -> Self {
            return Self(worker: worker, notificationSending: notificationSending)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public static func specification(
            userBy userid: UserID
        ) -> Self {
            return Self(userID: userid)
        }
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
                    .logMessage("notification sent", using: logging)
                    .map { sendingResults in
                        TestNotifications.Result(user, sendingResults: sendingResults)
                    }
            }
    }

}
