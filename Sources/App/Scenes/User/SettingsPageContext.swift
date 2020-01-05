import Domain

import Foundation

struct SettingsPageContext: Encodable {

    var userID: ID?

    var settings: UserSettings

    var form: SettingsPageFormContext

    fileprivate init(for user: UserRepresentation, from data: SettingsPageFormData? = nil) {
        self.userID = ID(user.id)

        self.settings = user.settings

        self.form = SettingsPageFormContext(from: data)
    }

}

// MARK: - Builder

enum SettingsPageContextBuilderError: Error {
    case missingRequiredUser
}

class SettingsPageContextBuilder {

    var user: UserRepresentation?

    var formData: SettingsPageFormData?

    @discardableResult
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withFormData(_ formData: SettingsPageFormData?) -> Self {
        self.formData = formData
        return self
    }

    func build() throws -> SettingsPageContext {
        guard let user = user else {
            throw SettingsPageContextBuilderError.missingRequiredUser
        }
        return SettingsPageContext(
            for: user,
            from: formData
        )
    }

}
