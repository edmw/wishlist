import Foundation

// MARK: ItemPageContext

struct ItemPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var item: ItemContext?

    var listTitle: String

    var userLists: [ListContext]?

    var form: ItemPageFormContext

    fileprivate init(
        for user: User,
        and list: List,
        with item: Item? = nil,
        and reservation: Reservation? = nil,
        from data: ItemPageFormData? = nil
    ) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        if let item = item {
            self.item = ItemContext(for: item, with: reservation)
        }
        else {
            self.item = nil
        }

        self.listTitle = list.title

        self.form = ItemPageFormContext(from: data)
    }

}

// MARK: - Builder

enum ItemPageContextBuilderError: Error {
    case missingRequiredUser
    case missingRequiredList
}

class ItemPageContextBuilder {

    var user: User?
    var list: List?
    var item: Item?
    var reservation: Reservation?
    var formData: ItemPageFormData?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forList(_ list: List) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withItem(_ item: Item?) -> Self {
        self.item = item
        return self
    }

    @discardableResult
    func withReservation(_ reservation: Reservation?) -> Self {
        self.reservation = reservation
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
            and: reservation,
            from: formData
        )
    }

}
