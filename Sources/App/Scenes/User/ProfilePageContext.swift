import Domain

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
        for user: UserRepresentation,
        invitations: [InvitationRepresentation]? = nil,
        from data: ProfilePageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.userNickName = user.nickName
        self.userFirstName = user.firstName
        self.userLastName = user.lastName
        self.userEmail = String(user.email)
        self.userLanguage = user.language
        self.userFirstLogin = user.firstLogin
        self.userLastLogin = user.lastLogin

        self.userSettings = user.settings

        self.showInvitations = invitations != nil && user.confidant

        self.maximumNumberOfInvitations = Invitation.maximumNumberOfInvitationsPerUser

        self.invitations = invitations?.map { invitation in InvitationContext(invitation) }

        self.form = ProfilePageFormContext(from: data)
    }

}

// MARK: - Builder

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
        return ProfilePageContext(
            for: user,
            invitations: invitations,
            from: formData
        )
    }

}
