// sourcery:inline:SettingsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: SettingsPageContext

enum SettingsPageContextBuilderError: Error {
  case missingRequiredUser
}

class SettingsPageContextBuilder {

    var user: UserRepresentation?
    var formData: SettingsPageFormData?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
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
        return .init(
            for: user,
            from: formData
        )
    }

}
// sourcery:end
