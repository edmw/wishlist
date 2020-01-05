import Foundation
import NIO

extension User {

    /// Authorizes access to the specified entity type for the this user.
    func authorize<E: Entity>(on entityType: E.Type) throws {
        // restrict access to invitations
        if entityType == Invitation.self {
            guard self.confidant == true else {
                throw AuthorizationError.accessibleForConfidantsOnly
            }
        }
        // allow all access to all other entities
        return
    }

}

extension EventLoopFuture where Expectation == User {

    func authorize<E: Entity>(on entityType: E.Type) -> EventLoopFuture<Expectation> {
        return self.map { user in
            try user.authorize(on: entityType)
            return user
        }
    }

}
