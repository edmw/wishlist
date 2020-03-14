// sourcery:inline:ListsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ListsPageContext

extension ListsPageContext {

    static var builder: ListsPageContextBuilder {
        return ListsPageContextBuilder()
    }

}

enum ListsPageContextBuilderError: Error {
  case missingRequiredUser
}

class ListsPageContextBuilder {

    var actions = PageActions()

    var user: UserRepresentation?
    var lists: [ListRepresentation]?

    @discardableResult
    func forUser(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withLists(_ lists: [ListRepresentation]?) -> Self {
        self.lists = lists
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
        return self
    }

    func build() throws -> ListsPageContext {
        guard let user = user else {
            throw ListsPageContextBuilderError.missingRequiredUser
        }
        var context = ListsPageContext(
            for: user,
            with: lists
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
