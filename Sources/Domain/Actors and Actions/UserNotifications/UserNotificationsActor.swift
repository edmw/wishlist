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

    let logging: MessageLogging
    let recording: EventRecording

    public required init(
        userRepository: UserRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.userRepository = userRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
    }

}
