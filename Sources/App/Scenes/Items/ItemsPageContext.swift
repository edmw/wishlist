import Domain

import Foundation
import Library

// MARK: ItemsPageContext

struct ItemsPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?
    var listID: ID?

    var userName: String
    var listTitle: String

    var maximumNumberOfItems: Int

    var items: [ItemContext]?
    var archivedItems: [ItemContext]?

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

        self.items = items?.compactMap { item in
            item.archival == false ? ItemContext(item) : nil
        }
        self.archivedItems = items?.compactMap { item in
            item.archival == true ? ItemContext(item) : nil
        }

        self.maskReservations = list.maskReservations
    }

}
