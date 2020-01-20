import Domain

import Foundation

struct ItemsPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var userName: String
    var listTitle: String

    var maximumNumberOfItems: Int

    var items: [ItemContext]?

    var maskReservations: Bool

    fileprivate init(
        for user: UserRepresentation,
        and list: ListRepresentation,
        with items: [ItemRepresentation]? = nil
    ) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.userName = user.firstName
        self.listTitle = list.title

        self.maximumNumberOfItems = Item.maximumNumberOfItemsPerList

        self.items = items?.map { item in ItemContext(item) }

        self.maskReservations = list.maskReservations
    }

}

// MARK: - Builder

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
        return .init(for: user, and: list, with: items)
    }

}
