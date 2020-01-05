import Foundation
import NIO

extension Invitation {

    /// Authorizes access to this invitation according to the confidentially of the user.
    /// - Parameter invitationRepository: Invitation repository
    /// - Parameter user: User which wants to access the invitation
    func authorize(in invitationRepository: InvitationRepository, for user: User) throws
        -> EventLoopFuture<Authorization<Invitation>>
    {
        return invitationRepository.owner(of: self).map { owner in
            // check if the invitation may be accessed by the given user
            return try self.authorize(for: user, owner: owner)
        }
    }

}

extension EventLoopFuture where Expectation == Invitation {

    func authorize(in repository: InvitationRepository, for user: User)
        throws -> EventLoopFuture<Authorization<Invitation>>
    {
        self.flatMap { invitation in try invitation.authorize(in: repository, for: user) }
    }

}
