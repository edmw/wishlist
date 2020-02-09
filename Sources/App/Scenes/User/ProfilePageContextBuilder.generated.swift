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

    var user: UserRepresentation?
    var invitations: [InvitationRepresentation]?
    var formData: ProfilePageFormData?

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
    func withFormData(_ formData: ProfilePageFormData?) -> Self {
        self.formData = formData
        return self
    }

    func build() throws -> ProfilePageContext {
        guard let user = user else {
            throw ProfilePageContextBuilderError.missingRequiredUser
        }
        return .init(
            for: user,
            invitations: invitations,
            from: formData
        )
    }

}
// sourcery:end
