import Foundation

struct ProfilePageContext: Encodable {

    var userID: ID?

    var userNickName: String?
    var userFirstName: String
    var userLastName: String
    var userEmail: String
    var userLanguage: String?
    var userFirstLogin: Date?
    var userLastLogin: Date?

    var userSettings: UserSettings

    var showInvitations: Bool

    var maximumNumberOfInvitations: Int

    var invitations: [InvitationContext]?

    var form: ProfilePageFormContext

    fileprivate init(
        for user: User,
        invitations: [InvitationContext]? = nil,
        from data: ProfilePageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.userNickName = user.nickName
        self.userFirstName = user.firstName
        self.userLastName = user.lastName
        self.userEmail = user.email
        self.userLanguage = user.language
        self.userFirstLogin = user.firstLogin
        self.userLastLogin = user.lastLogin

        self.userSettings = user.settings

        self.showInvitations = invitations != nil && user.confidant

        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.invitations = invitations

        self.form = ProfilePageFormContext(from: data)
    }

}

// MARK: - Builder

enum ProfilePageContextBuilderError: Error {
    case missingRequiredUser
}

class ProfilePageContextBuilder {

    var user: User?
    var invitationContexts: [InvitationContext]?

    var formData: ProfilePageFormData?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withInvitationContexts(_ invitationContexts: [InvitationContext]) -> Self {
        self.invitationContexts = invitationContexts
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
        return ProfilePageContext(
            for: user,
            invitations: invitationContexts,
            from: formData
        )
    }

}
