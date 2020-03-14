// sourcery:inline:ProfilePageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ProfilePageContext

extension ProfilePageContext {

    static var builder: ProfilePageContextBuilder {
        return ProfilePageContextBuilder()
    }

}

enum ProfilePageContextBuilderError: Error {
  case missingRequiredUser
}

class ProfilePageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var invitations: [InvitationRepresentation]?
    var editingContext: ProfileEditingContext?

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
    func withEditing(_ editingContext: ProfileEditingContext?) -> Self {
        self.editingContext = editingContext
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> ProfilePageContext {
        guard let user = user else {
            throw ProfilePageContextBuilderError.missingRequiredUser
        }
        var context = ProfilePageContext(
            for: user,
            invitations: invitations,
            from: editingContext
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
