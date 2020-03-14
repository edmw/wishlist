// sourcery:inline:InvitationsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: InvitationsPageContext

extension InvitationsPageContext {

    static var builder: InvitationsPageContextBuilder {
        return InvitationsPageContextBuilder()
    }

}

enum InvitationsPageContextBuilderError: Error {
  case missingRequiredUser
}

class InvitationsPageContextBuilder {

    var actions = PageActions()

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

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> InvitationsPageContext {
        guard let user = user else {
            throw InvitationsPageContextBuilderError.missingRequiredUser
        }
        var context = InvitationsPageContext(
            for: user,
            with: invitations
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
