import Domain

import Vapor

/// This structures holds all the input given by the user into the list form.
/// In contrast to `ListRepresentation` and `ListData` this contains only editable properties.
struct ListPageFormData: Content {
    // swiftlint:disable discouraged_optional_boolean

    let inputTitle: String
    let inputVisibility: String
    let inputMaskReservations: Bool?
    let inputItemsSorting: String?

    init() {
        self.inputTitle = ""
        self.inputVisibility = "private"
        self.inputMaskReservations = false
        self.inputItemsSorting = nil
    }

    init(from list: ListRepresentation) {
        self.inputTitle = list.title
        self.inputVisibility = list.visibility
        self.inputMaskReservations = list.maskReservations
        self.inputItemsSorting = list.itemsSorting
    }

}

extension ListValues {

    init(from formdata: ListPageFormData) {
        let itemsSorting: ItemsSorting?
        if let inputItemsSorting = formdata.inputItemsSorting {
            itemsSorting = ItemsSorting(inputItemsSorting)
        }
        else {
            itemsSorting = nil
        }
        self.init(
            title: formdata.inputTitle,
            visibility: formdata.inputVisibility,
            createdAt: nil,
            modifiedAt: nil,
            maskReservations: formdata.inputMaskReservations ?? false,
            itemsSorting: itemsSorting,
            items: nil
        )
    }

}
