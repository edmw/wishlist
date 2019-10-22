import Foundation

struct ItemsPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var userName: String
    var listTitle: String

    var maximumNumberOfItems: Int

    var items: [ItemContext]?

    var maskReservations: Bool

    fileprivate init(for user: User, and list: List, with items: [ItemContext]? = nil) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.userName = user.firstName
        self.listTitle = list.title

        self.maximumNumberOfItems = Item.maximumNumberOfItemsPerList

        self.items = items

        self.maskReservations = list.options.contains(.maskReservations)
    }

}

// MARK: - Builder

enum ItemsPageContextBuilderError: Error {
    case missingRequiredUser
    case missingRequiredList
}

class ItemsPageContextBuilder {

    var user: User?
    var list: List?

    var itemContexts: [ItemContext]?

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
    func withItemContexts(_ itemContexts: [ItemContext]?) -> Self {
        self.itemContexts = itemContexts
        return self
    }

    func build() throws -> ItemsPageContext {
        guard let user = user else {
            throw ItemsPageContextBuilderError.missingRequiredUser
        }
        guard let list = list else {
            throw ItemsPageContextBuilderError.missingRequiredList
        }
        return ItemsPageContext(
            for: user,
            and: list,
            with: itemContexts
        )
    }

}
