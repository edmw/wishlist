import Foundation
import NIO

// MARK: EmailSendingProvider

public protocol EmailSendingProvider {

    /// Sends an invitation email for the specified user.
    func dispatchSendInvitationEmail(
        _ invitation: InvitationRepresentation,
        for user: UserRepresentation
    ) throws -> EventLoopFuture<Bool>

}
