import Foundation
import NIO

// MARK: CreateInvitation

public struct CreateInvitation: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries, SendInvitationBoundaries {
        public let worker: EventLoop
        public let emailSending: EmailSendingProvider
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let values: InvitationValues
        public let sendEmail: Bool
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let invitation: InvitationRepresentation
        internal init(_ user: User, _ inivitation: Invitation) {
            self.user = user.representation
            self.invitation = inivitation.representation
        }
    }

    // MARK: -

    internal let actor: () -> CreateInvitationActor

    internal init(actor: @escaping @autoclosure () -> CreateInvitationActor) {
        self.actor = actor
    }

    // MARK: Execute

    internal func execute(
        with values: InvitationValues,
        for user: User,
        in boundaries: Boundaries
    ) throws -> EventLoopFuture<InvitationNote> {
        let actor = self.actor()
        let invitationRepository = actor.invitationRepository
        return try values.validate(for: user, using: invitationRepository)
            .flatMap { values in
                // create invitation
                let invitation = try Invitation(for: user, from: values)
                return invitationRepository
                    .save(invitation: invitation)
                    .map { invitation in
                        .init(invitation: invitation, inviter: user)
                    }
            }
            .catchFlatMap { error in
                if let valuesError = error as? ValuesError<InvitationValues> {
                    throw CreateInvitationValidationError(user: user, error: valuesError)
                }
                throw error
            }
    }

}

// MARK: -

protocol CreateInvitationActor {
    var invitationRepository: InvitationRepository { get }
    var logging: MessageLogging { get }
    var recording: EventRecording { get }
}

protocol CreateInvitationError: ActionError {
    var user: User { get }
}

struct CreateInvitationValidationError: CreateInvitationError {
    var user: User
    var error: ValuesError<InvitationValues>
}

// MARK: - Actor

extension DomainUserInvitationsActor {

    // MARK: createInvitation

    public func createInvitation(
        _ specification: CreateInvitation.Specification,
        _ boundaries: CreateInvitation.Boundaries
    ) throws -> EventLoopFuture<CreateInvitation.Result> {
        let invitationRepository = self.invitationRepository
        let logging = self.logging
        let recording = self.recording
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .authorize(on: Invitation.self)
            .flatMap { user in
                return try CreateInvitation(actor: self)
                    .execute(with: specification.values, for: user, in: boundaries)
                    .logMessage(.createInvitationNote, using: logging)
                    .recordEvent("created", using: recording)
                    .flatMap { note in
                        var future = boundaries.worker.makeSucceededFuture(note)
                        if specification.sendEmail {
                            future = future
                                .sendInvitationNote(in: invitationRepository, on: boundaries)
                                .logMessage(.createInvitationNoteSent, using: logging)
                                .recordEvent("sent", using: recording)
                        }
                        return future.map { note in .init(note.inviter, note.invitation) }
                    }
                    .catchMap { error in
                        if let createError = error as? CreateInvitationValidationError {
                            logging.debug("Invitation creation validation error: \(createError)")
                            let error = createError.error
                            throw UserInvitationsActorError
                                .validationError(user.representation, nil, error)
                        }
                        throw error
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static var createInvitationNote: LoggingMessageRoot<InvitationNote> {
        return .init({ note in
            LoggingMessage(
                label: "Create Invitation",
                subject: note.invitation,
                loggables: [note.inviter]
            )
        })
    }

    fileprivate static var createInvitationNoteSent: LoggingMessageRoot<InvitationNote> {
        return .init({ note in
            LoggingMessage(
                label: "Create Invitation (Sent)",
                subject: note.invitation,
                loggables: [note.inviter]
            )
        })
    }

}
