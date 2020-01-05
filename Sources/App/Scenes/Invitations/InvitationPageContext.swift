import Domain

import Foundation

struct InvitationPageContext: Encodable {

    var userID: ID?

    var invitation: InvitationContext?

    var form: InvitationPageFormContext

    var sendSuccess: Bool = false

    fileprivate init(
        for user: UserRepresentation,
        with invitation: InvitationRepresentation? = nil,
        from data: InvitationPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.invitation = InvitationContext(invitation)

        self.form = InvitationPageFormContext(from: data)
    }

}

// MARK: - Builder

enum InvitationPageContextBuilderError: Error {
    case missingRequiredUser
}

class InvitationPageContextBuilder {
    // swiftlint:disable discouraged_optional_boolean

    var user: UserRepresentation?
    var invitation: InvitationRepresentation?

    var formData: InvitationPageFormData?

    var sendSuccess: Bool?

    @discardableResult
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forInvitationRepresentation(_ invitation: InvitationRepresentation?) -> Self {
        self.invitation = invitation
        return self
    }

    @discardableResult
    func with(_ user: UserRepresentation, _ invitation: InvitationRepresentation?) -> Self {
        self.user = user
        self.invitation = invitation
        return self
    }

    @discardableResult
    func withFormData(_ formData: InvitationPageFormData?) -> Self {
        self.formData = formData
        return self
    }

    @discardableResult
    func withSendSuccess(_ sendSuccess: Bool?) -> Self {
        self.sendSuccess = sendSuccess
        return self
    }

    func build() throws -> InvitationPageContext {
        guard let user = user else {
            throw InvitationPageContextBuilderError.missingRequiredUser
        }
        var context = InvitationPageContext(
            for: user,
            with: invitation,
            from: formData
        )
        context.sendSuccess = sendSuccess ?? false
        return context
    }

}
