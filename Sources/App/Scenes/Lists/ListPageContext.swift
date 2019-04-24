import Foundation

struct ListPageContext: Encodable {

    var userID: ID?

    var list: ListContext?

    var form: ListPageFormContext

    init(
        for user: User,
        with list: List? = nil,
        from data: ListPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        if let list = list {
            self.list = ListContext(for: list)
        }
        else {
            self.list = nil
        }

        self.form = ListPageFormContext(from: data)
    }

}
