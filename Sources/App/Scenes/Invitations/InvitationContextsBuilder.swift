import Vapor

// MARK: InvitationContextsBuilder

class InvitationContextsBuilder {

    let invitationRepository: InvitationRepository

    /// Builder for invitation contexts.
    /// - Parameter invitationRepository: Invitation repository
    init(_ invitationRepository: InvitationRepository) {
        self.invitationRepository = invitationRepository
    }

    var user: User?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    func build(on worker: Worker) throws -> EventLoopFuture<[InvitationContext]> {
        guard let user = user else {
            throw InvitationContextsBuilderError.missingRequiredUser
        }

        return try self.invitationRepository
            .all(for: user)
            .map { allInvitations in
                return allInvitations.map { invitation in
                    InvitationContext(for: invitation)
                }
            }
    }

}

enum InvitationContextsBuilderError: Error {
    case missingRequiredUser
}
