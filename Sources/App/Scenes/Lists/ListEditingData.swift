import Domain

// MARK: ListEditingData

/// This structures holds all the input given by the user into the list form.
/// In contrast to `ListRepresentation` and `ListData` this contains only editable properties.
struct ListEditingData: Codable {

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

    init(from data: ListEditingData) {
        self.init(
            title: data.inputTitle,
            visibility: data.inputVisibility,
            createdAt: nil,
            modifiedAt: nil,
            maskReservations: data.inputMaskReservations ?? false,
            itemsSorting: data.inputItemsSorting,
            items: nil
        )
    }

}
