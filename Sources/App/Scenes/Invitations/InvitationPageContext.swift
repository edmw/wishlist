import Foundation

struct InvitationPageContext: Encodable {

    var userID: ID?

    var invitation: InvitationContext?

    var form: InvitationPageFormContext

    var sendSuccess: Bool = false

    fileprivate init(
        for user: User,
        with invitation: Invitation? = nil,
        from data: InvitationPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        if let invitation = invitation {
            self.invitation = InvitationContext(for: invitation)
        }
        else {
            self.invitation = nil
        }

        self.form = InvitationPageFormContext(from: data)
    }

}

// MARK: - Builder

enum InvitationPageContextBuilderError: Error {
    case missingRequiredUser
}

class InvitationPageContextBuilder {
    // swiftlint:disable discouraged_optional_boolean

    var user: User?
    var invitation: Invitation?

    var formData: InvitationPageFormData?

    var sendSuccess: Bool?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forInvitation(_ invitation: Invitation) -> Self {
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
