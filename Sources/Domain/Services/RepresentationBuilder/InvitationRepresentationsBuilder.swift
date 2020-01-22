import Foundation
import NIO

import Library

// MARK: InvitationRepresentationsBuilder

class InvitationRepresentationsBuilder {

    let invitationRepository: InvitationRepository

    /// Builder for invitation representations.
    /// - Parameter invitationRepository: Invitation repository
    init(_ invitationRepository: InvitationRepository) {
        self.invitationRepository = invitationRepository
    }

    var user: User?

    func reset() -> Self {
        self.user = nil
        return self
    }

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    func build(on worker: EventLoop) throws -> EventLoopFuture<[InvitationRepresentation]> {
        guard let user = user else {
            throw InvitationRepresentationsBuilderError.missingRequiredUser
        }

        return try self.invitationRepository
            .all(for: user)
            .map { allInvitations in
                allInvitations.map { invitation in invitation.representation }
            }
    }

}

enum InvitationRepresentationsBuilderError: Error {
    case missingRequiredUser
}
