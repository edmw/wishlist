// sourcery:inline:ItemPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ItemPageContext

extension ItemPageContext {

    static var builder: ItemPageContextBuilder {
        return ItemPageContextBuilder()
    }

}

enum ItemPageContextBuilderError: Error {
  case missingRequiredUser
  case missingRequiredList
}

class ItemPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var list: ListRepresentation?
    var item: ItemRepresentation?
    var editingContext: ItemEditingContext?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forList(_ list: ListRepresentation) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withItem(_ item: ItemRepresentation?) -> Self {
        self.item = item
        return self
    }

    @discardableResult
    func withEditing(_ editingContext: ItemEditingContext?) -> Self {
        self.editingContext = editingContext
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> ItemPageContext {
        guard let user = user else {
            throw ItemPageContextBuilderError.missingRequiredUser
        }
        guard let list = list else {
            throw ItemPageContextBuilderError.missingRequiredList
        }
        var context = ItemPageContext(
            for: user,
            and: list,
            with: item,
            editingContext: editingContext
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
