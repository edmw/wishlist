import Vapor

/// This structures holds all the input given by the user into the list form.
/// In contrast to `ListData` this contains only editable properties.
struct ListPageFormData: Content {
    // swiftlint:disable discouraged_optional_boolean

    let inputTitle: String
    let inputVisibility: Visibility
    let inputMaskReservations: Bool?
    let inputItemsSorting: ItemsSorting?

    init() {
        self.inputTitle = ""
        self.inputVisibility = .´private´
        self.inputMaskReservations = false
        self.inputItemsSorting = nil
    }

    init(from list: List) {
        self.inputTitle = list.title
        self.inputVisibility = list.visibility
        self.inputMaskReservations = list.options.contains(.maskReservations)
        self.inputItemsSorting = list.itemsSorting
    }

}

extension ListData {

    init(from formdata: ListPageFormData) {
        self.title = formdata.inputTitle
        self.visibility = formdata.inputVisibility
        self.createdAt = nil
        self.modifiedAt = nil
        var options: List.Options = []
        if let maskReservations = formdata.inputMaskReservations, maskReservations == true {
            options = options.union([.maskReservations])
        }
        self.options = options
        self.itemsSorting = formdata.inputItemsSorting
        self.items = nil
    }

}
