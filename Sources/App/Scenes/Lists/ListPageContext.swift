import Domain

import Foundation

struct ListPageContext: PageContext, AutoPageContextBuilder {

    var userID: ID?

    var list: ListContext?

    var form: ListPageFormContext

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with list: ListRepresentation? = nil,
        from formData: ListPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.list = ListContext(list)

        self.form = ListPageFormContext(from: formData)
    }

}
