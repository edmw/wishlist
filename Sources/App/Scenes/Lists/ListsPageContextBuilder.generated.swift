// sourcery:inline:ListsPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ListsPageContext

enum ListsPageContextBuilderError: Error {
  case missingRequiredUser
}

class ListsPageContextBuilder {

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

    func build() throws -> ListsPageContext {
        guard let user = user else {
            throw ListsPageContextBuilderError.missingRequiredUser
        }
        return .init(
            for: user,
            with: lists
        )
    }

}
// sourcery:end
