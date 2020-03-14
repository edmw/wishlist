// sourcery:inline:ListPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ListPageContext

extension ListPageContext {

    static var builder: ListPageContextBuilder {
        return ListPageContextBuilder()
    }

}

enum ListPageContextBuilderError: Error {
  case missingRequiredUser
}

class ListPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var list: ListRepresentation?
    var editingContext: ListEditingContext?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withList(_ list: ListRepresentation?) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withEditing(_ editingContext: ListEditingContext?) -> Self {
        self.editingContext = editingContext
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> ListPageContext {
        guard let user = user else {
            throw ListPageContextBuilderError.missingRequiredUser
        }
        var context = ListPageContext(
            for: user,
            with: list,
            from: editingContext
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
