// sourcery:inline:ItemsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ItemsPageContext

extension ItemsPageContext {

    static var builder: ItemsPageContextBuilder {
        return ItemsPageContextBuilder()
    }

}

enum ItemsPageContextBuilderError: Error {
  case missingRequiredUser
  case missingRequiredList
}

class ItemsPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var list: ListRepresentation?
    var items: [ItemRepresentation]?

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
    func withItems(_ items: [ItemRepresentation]?) -> Self {
        self.items = items
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> ItemsPageContext {
        guard let user = user else {
            throw ItemsPageContextBuilderError.missingRequiredUser
        }
        guard let list = list else {
            throw ItemsPageContextBuilderError.missingRequiredList
        }
        var context = ItemsPageContext(
            for: user,
            and: list,
            with: items
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
