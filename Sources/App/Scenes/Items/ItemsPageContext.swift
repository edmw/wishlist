import Domain

import Foundation

struct ItemsPageContext: PageContext, AutoPageContextBuilder {

    var userID: ID?
    var listID: ID?

    var userName: String
    var listTitle: String

    var maximumNumberOfItems: Int

    var items: [ItemContext]?

    var maskReservations: Bool

    // sourcery: AutoPageContextBuilderInitializer
    init(
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
