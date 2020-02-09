import Foundation
import NIO

// MARK: SendInvitationEmail

public protocol SendInvitationBoundaries {
    var worker: EventLoop { get }
    var emailSending: EmailSendingProvider { get }
}

public struct SendInvitationEmail: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries, SendInvitationBoundaries {
        public let worker: EventLoop
        public let emailSending: EmailSendingProvider
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public let invitationID: InvitationID
        public static func specification(
            userBy userid: UserID,
            invitation invitationid: InvitationID
        ) -> Self {
            return Self(userID: userid, invitationID: invitationid)
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let invitation: InvitationRepresentation
        internal init(_ user: User, _ invitation: Invitation) {
            self.user = user.representation
            self.invitation = invitation.representation
        }
    }

}

// MARK: - Actor

extension DomainUserInvitationsActor {

    // MARK: sendInvitationEmail

    public func sendInvitationEmail(
        _ specification: SendInvitationEmail.Specification,
        _ boundaries: SendInvitationEmail.Boundaries
    ) throws -> EventLoopFuture<SendInvitationEmail.Result> {
        let logging = self.logging
        let invitationRepository = self.invitationRepository
        // find user and authorize access to invitations for user
        // IMPROVEMENT: lookup both, invitation and user and authorize for user
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserInvitationsActorError.invalidUser)
            .authorize(on: Invitation.self)
            .flatMap { user in
                // find invitation and authorize access to this invitation for user
                return try invitationRepository
                    .find(by: specification.invitationID)
                    .unwrap(or: UserInvitationsActorError.invalidInvitation)
                    .authorize(in: invitationRepository, for: user)
                    .map { authorization -> InvitationNote in
                        .init(invitation: authorization.entity, inviter: authorization.owner)
                    }
                    .sendInvitationNote(in: invitationRepository, on: boundaries)
                    .logMessage(.sendInvitationNote, using: logging)
                    .map { note in
                        return .init(note.inviter, note.invitation)
                    }
            }
    }

}

// MARK: send Invitation

extension EventLoopFuture where Expectation == InvitationNote {

    /// Sends an invitation mail and updates sent date of invitation on succes.
    func sendInvitationNote(
        when enabled: Bool = true,
        in invitationRepository: InvitationRepository,
        on boundaries: SendInvitationBoundaries
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap { note in
            guard enabled else {
                return boundaries.worker.makeSucceededFuture(note)
            }
            let invitation = note.invitation
            let inviter = note.inviter
            return try boundaries.emailSending
                .sendInvitationEmail(invitation.representation, for: inviter.representation)
                .flatMap { success in
                    if success {
                        invitation.sentAt = Date()
                        return invitationRepository
                            .save(invitation: invitation)
                            .transform(to: note)
                    }
                    else {
                        return boundaries.worker.makeSucceededFuture(note)
                    }
                }
        }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static var sendInvitationNote: LoggingMessageRoot<InvitationNote> {
        return .init({ note in
            LoggingMessage(
                label: "Send Invitation Note",
                subject: note.invitation,
                loggables: [note.inviter]
            )
        })
    }

}
