// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Foundation

// MARK: ItemsPageContext

enum ItemsPageContextBuilderError: Error {
  case missingRequiredUser
  case missingRequiredList
}

class ItemsPageContextBuilder {

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

    func build() throws -> ItemsPageContext {
        guard let user = user else {
            throw ItemsPageContextBuilderError.missingRequiredUser
        }
        guard let list = list else {
            throw ItemsPageContextBuilderError.missingRequiredList
        }
        return .init(
            for: user,
            and: list,
            with: items
        )
    }

}
