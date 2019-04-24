import Vapor

/// This structures holds all the input given by the user into the list form.
/// In contrast to `ListData` this contains only editable properties.
struct ListPageFormData: Content {

    let inputName: String
    let inputVisibility: Visibility
    let inputItemsSorting: ItemsSorting?

    init() {
        self.inputName = ""
        self.inputVisibility = .´private´
        self.inputItemsSorting = nil
    }

    init(from list: List) {
        self.inputName = list.name
        self.inputVisibility = list.visibility
        self.inputItemsSorting = list.itemsSorting
    }

}

extension ListData {

    init(from formdata: ListPageFormData) {
        self.name = formdata.inputName
        self.visibility = formdata.inputVisibility
        self.createdAt = nil
        self.modifiedAt = nil
        self.itemsSorting = formdata.inputItemsSorting
        self.items = nil
    }

}
