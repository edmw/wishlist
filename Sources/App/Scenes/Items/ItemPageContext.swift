import Domain

import Foundation

// MARK: ItemPageContext

struct ItemPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?
    var listID: ID?

    var item: ItemContext?

    var listTitle: String

    // for MoveItem form
    var userLists: [ListContext]?

    var form: ItemEditingContext

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        and list: ListRepresentation,
        with item: ItemRepresentation? = nil,
        editingContext: ItemEditingContext? = nil
    ) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.item = ItemContext(item)

        self.listTitle = list.title

        self.form = editingContext ?? .empty
    }

}
