// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Foundation

// MARK: ListPageContext

enum ListPageContextBuilderError: Error {
  case missingRequiredUser
}

class ListPageContextBuilder {

    var user: UserRepresentation?
    var list: ListRepresentation?
    var formData: ListPageFormData?

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
    func withFormData(_ formData: ListPageFormData?) -> Self {
        self.formData = formData
        return self
    }

    func build() throws -> ListPageContext {
        guard let user = user else {
            throw ListPageContextBuilderError.missingRequiredUser
        }
        return .init(
            for: user,
            with: list,
            from: formData
        )
    }

}
