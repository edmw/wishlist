import Domain

import Foundation

// MARK: ItemPageContext

struct ItemPageContext: PageContext, AutoPageContextBuilder {

    var userID: ID?
    var listID: ID?

    var item: ItemContext?

    var listTitle: String

    // for MoveItem form
    var userLists: [ListContext]?

    var form: ItemPageFormContext

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        and list: ListRepresentation,
        with item: ItemRepresentation? = nil,
        from formData: ItemPageFormData? = nil
    ) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        self.item = ItemContext(item)

        self.listTitle = list.title

        self.form = ItemPageFormContext(from: formData)
    }

}
