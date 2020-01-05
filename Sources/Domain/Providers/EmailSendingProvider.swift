import Foundation
import NIO

// MARK: EmailSendingProvider

public protocol EmailSendingProvider {

    /// Sends an invitation email for the specified user.
    func sendInvitationEmail(_ invitation: InvitationRepresentation, for user: UserRepresentation)
        throws -> EventLoopFuture<Bool>

}
