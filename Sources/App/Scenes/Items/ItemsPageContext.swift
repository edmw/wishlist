import Foundation

struct ItemsPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var userName: String
    var listTitle: String

    var maximumNumberOfItems: Int

    var items: [ItemContext]?

    var maskReservations: Bool

    init(for user: User, and list: List, with items: [ItemContext]? = nil) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.userName = user.firstName
        self.listTitle = list.title

        self.maximumNumberOfItems = Item.maximumNumberOfItemsPerList

        self.items = items

        self.maskReservations = list.options.contains(.maskReservations)
    }

}
