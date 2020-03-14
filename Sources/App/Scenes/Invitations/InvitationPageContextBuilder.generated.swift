// sourcery:inline:InvitationPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: InvitationPageContext

extension InvitationPageContext {

    static var builder: InvitationPageContextBuilder {
        return InvitationPageContextBuilder()
    }

}

enum InvitationPageContextBuilderError: Error {
  case missingRequiredUser
}

class InvitationPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var invitation: InvitationRepresentation?
    var editingContext: InvitationEditingContext?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withInvitation(_ invitation: InvitationRepresentation?) -> Self {
        self.invitation = invitation
        return self
    }

    @discardableResult
    func withEditing(_ editingContext: InvitationEditingContext?) -> Self {
        self.editingContext = editingContext
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> InvitationPageContext {
        guard let user = user else {
            throw InvitationPageContextBuilderError.missingRequiredUser
        }
        var context = InvitationPageContext(
            for: user,
            with: invitation,
            from: editingContext
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
