import Foundation

struct ItemPageContext: Encodable {

    var userID: ID?
    var listID: ID?

    var item: ItemContext?

    var listTitle: String

    var form: ItemPageFormContext

    init(
        for user: User,
        and list: List,
        with item: Item? = nil,
        and reservation: Reservation? = nil,
        from data: ItemPageFormData? = nil
    ) {
        self.userID = ID(user.id)
        self.listID = ID(list.id)

        if let item = item {
            self.item = ItemContext(for: item, with: reservation)
        }
        else {
            self.item = nil
        }

        self.listTitle = list.title

        self.form = ItemPageFormContext(from: data)
    }

}
