import Foundation
import NIO

// MARK: UserNotificationsActor

/// Notifications use cases for the user.
public protocol UserNotificationsActor {

    func testNotifications(
        _ specification: TestNotifications.Specification,
        _ boundaries: TestNotifications.Boundaries
    ) throws -> EventLoopFuture<UserNotificationsResult>

}

/// Errors thrown by the User Notifications actor.
enum UserNotificationsActorError: Error {
    case invalidUser
}

/// This is the domain’s implementation of the Notifications use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserNotificationsActor: UserNotificationsActor {
    let userRepository: UserRepository

    let logging: MessageLoggingProvider
    let recording: EventRecordingProvider

    public required init(
        _ userRepository: UserRepository,
        _ logging: MessageLoggingProvider,
        _ recording: EventRecordingProvider
    ) {
        self.userRepository = userRepository
        self.logging = logging
        self.recording = recording
    }

}
