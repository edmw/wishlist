import Foundation

struct ItemsPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var userName: String
    var listName: String

    var maximumNumberOfItems: Int

    var items: [ItemContext]?

    init(for user: User, and list: List, with items: [ItemContext]? = nil) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.userName = user.firstName
        self.listName = list.name

        self.maximumNumberOfItems = Item.maximumNumberOfItemsPerList

        self.items = items
    }

}