import Foundation
import NIO

// MARK: UserProfileActor

/// Profile use cases for the user.
public protocol UserProfileActor: Actor {

    func getProfileAndInvitations(
        _ specification: GetProfileAndInvitations.Specification,
        _ boundaries: GetProfileAndInvitations.Boundaries
    ) throws -> EventLoopFuture<GetProfileAndInvitations.Result>

    func requestProfileEditing(
        _ specification: RequestProfileEditing.Specification,
        _ boundaries: RequestProfileEditing.Boundaries
    ) throws -> EventLoopFuture<RequestProfileEditing.Result>

    func updateProfile(
        _ specification: UpdateProfile.Specification,
        _ boundaries: UpdateProfile.Boundaries
    ) throws -> EventLoopFuture<UpdateProfile.Result>

}

/// This is the domain’s implementation of the Profile use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserProfileActor: UserProfileActor,
    UpdateProfileActor
{
    let userRepository: UserRepository
    let invitationRepository: InvitationRepository

    let logging: MessageLogging
    let recording: EventRecording

    let invitationRepresentationsBuilder: InvitationRepresentationsBuilder

    public required init(
        userRepository: UserRepository,
        invitationRepository: InvitationRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.userRepository = userRepository
        self.invitationRepository = invitationRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
        self.invitationRepresentationsBuilder
            = InvitationRepresentationsBuilder(invitationRepository)
    }

}
