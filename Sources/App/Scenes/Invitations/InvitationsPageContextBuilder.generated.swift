// sourcery:inline:InvitationsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: InvitationsPageContext

enum InvitationsPageContextBuilderError: Error {
  case missingRequiredUser
}

class InvitationsPageContextBuilder {

    var user: UserRepresentation?
    var invitations: [InvitationRepresentation]?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withInvitations(_ invitations: [InvitationRepresentation]?) -> Self {
        self.invitations = invitations
        return self
    }

    func build() throws -> InvitationsPageContext {
        guard let user = user else {
            throw InvitationsPageContextBuilderError.missingRequiredUser
        }
        return .init(
            for: user,
            with: invitations
        )
    }

}
// sourcery:end
