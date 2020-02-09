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

    var user: UserRepresentation?
    var invitation: InvitationRepresentation?
    var formData: InvitationPageFormData?

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
    func withFormData(_ formData: InvitationPageFormData?) -> Self {
        self.formData = formData
        return self
    }

    func build() throws -> InvitationPageContext {
        guard let user = user else {
            throw InvitationPageContextBuilderError.missingRequiredUser
        }
        return .init(
            for: user,
            with: invitation,
            from: formData
        )
    }

}
// sourcery:end
