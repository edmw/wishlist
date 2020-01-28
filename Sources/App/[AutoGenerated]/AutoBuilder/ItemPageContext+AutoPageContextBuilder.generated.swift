// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Foundation

// MARK: ItemPageContext

enum ItemPageContextBuilderError: Error {
  case missingRequiredUser
  case missingRequiredList
}

class ItemPageContextBuilder {

    var user: UserRepresentation?
    var list: ListRepresentation?
    var item: ItemRepresentation?
    var formData: ItemPageFormData?

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
    func withFormData(_ formData: ItemPageFormData?) -> Self {
        self.formData = formData
        return self
    }

    func build() throws -> ItemPageContext {
        guard let user = user else {
            throw ItemPageContextBuilderError.missingRequiredUser
        }
        guard let list = list else {
            throw ItemPageContextBuilderError.missingRequiredList
        }
        return .init(
            for: user,
            and: list,
            with: item,
            from: formData
        )
    }

}
