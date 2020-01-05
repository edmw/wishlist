import Foundation
import NIO

// MARK: UserSettingsActor

/// Settings use cases for the user.
public protocol UserSettingsActor {

    func requestSettingsEditing(
        _ specification: RequestSettingsEditing.Specification,
        _ boundaries: RequestSettingsEditing.Boundaries
    ) throws -> EventLoopFuture<RequestSettingsEditing.Result>

    func updateSettings(
        _ specification: UpdateSettings.Specification,
        _ boundaries: UpdateSettings.Boundaries
    ) throws -> EventLoopFuture<UpdateSettings.Result>

}

/// Errors thrown by the User Settings actor.
public enum UserSettingsActorError: Error {
    case invalidUser
    case validationError(UserRepresentation, ValuesError<UserSettings>)
}

/// This is the domain’s implementation of the Settings use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserSettingsActor: UserSettingsActor,
    UpdateSettingsActor
{
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
