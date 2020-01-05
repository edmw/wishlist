import Domain

import Foundation

// MARK: ItemPageContext

struct ItemPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var item: ItemContext?

    var listTitle: String

    // for MoveItem form
    var userLists: [ListContext]?

    var form: ItemPageFormContext

    fileprivate init(
        for user: UserRepresentation,
        and list: ListRepresentation,
        with item: ItemRepresentation? = nil,
        from data: ItemPageFormData? = nil
    ) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.item = ItemContext(item)

        self.listTitle = list.title

        self.form = ItemPageFormContext(from: data)
    }

}

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
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forListRepresentation(_ list: ListRepresentation) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withItemRepresentation(_ item: ItemRepresentation?) -> Self {
        self.item = item
        return self
    }

    @discardableResult
    func with(
        _ user: UserRepresentation,
        _ list: ListRepresentation,
        _ item: ItemRepresentation?
    ) -> Self {
        self.user = user
        self.list = list
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
        return ItemPageContext(
            for: user,
            and: list,
            with: item,
            from: formData
        )
    }

}
