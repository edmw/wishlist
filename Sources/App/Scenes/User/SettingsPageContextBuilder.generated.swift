// sourcery:inline:SettingsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: SettingsPageContext

extension SettingsPageContext {

    static var builder: SettingsPageContextBuilder {
        return SettingsPageContextBuilder()
    }

}

enum SettingsPageContextBuilderError: Error {
  case missingRequiredUser
}

class SettingsPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var editingContext: SettingsEditingContext?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withEditing(_ editingContext: SettingsEditingContext?) -> Self {
        self.editingContext = editingContext
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> SettingsPageContext {
        guard let user = user else {
            throw SettingsPageContextBuilderError.missingRequiredUser
        }
        var context = SettingsPageContext(
            for: user,
            from: editingContext
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
