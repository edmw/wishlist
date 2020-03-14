import Domain

import Foundation

// MARK: ListPageContext

struct ListPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?

    var list: ListContext?

    var form: ListEditingContext

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with list: ListRepresentation? = nil,
        from editingContext: ListEditingContext? = nil
    ) {
        self.userID = ID(user.id)

        self.list = ListContext(list)

        self.form = editingContext ?? .empty
    }

}
