import Domain

import Foundation

struct ListPageContext: Encodable {

    var userID: ID?

    var list: ListContext?

    var form: ListPageFormContext

    fileprivate init(
        for user: UserRepresentation,
        with list: ListRepresentation? = nil,
        from data: ListPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.list = ListContext(list)

        self.form = ListPageFormContext(from: data)
    }

}

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
    func with(_ user: UserRepresentation, _ list: ListRepresentation?) -> Self {
        self.user = user
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
            throw ItemPageContextBuilderError.missingRequiredUser
        }
        return ListPageContext(
            for: user,
            with: list,
            from: formData
        )
    }

}
