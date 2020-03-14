import Library
import Domain

// MARK: ItemEditingData

/// This structures holds all the input given by the user into the item form.
/// In contrast to `ItemRepresentation` and `ItemData` this contains only editable properties.
struct ItemEditingData: Codable {

    let inputTitle: String
    let inputText: String
    let inputPreference: String
    let inputURL: String
    let inputImageURL: String

    init() {
        self.inputTitle = ""
        self.inputText = ""
        self.inputPreference = "normal"
        self.inputURL = ""
        self.inputImageURL = ""
    }

    init(from item: ItemRepresentation) {
        self.inputTitle = item.title
        self.inputText = item.text
        self.inputPreference = item.preference
        self.inputURL = item.url ??? ""
        self.inputImageURL = item.imageURL ??? ""
    }

}

extension ItemValues {

    init(from data: ItemEditingData) {
        self.init(
            title: data.inputTitle,
            text: data.inputText,
            preference: data.inputPreference,
            url: data.inputURL,
            imageURL: data.inputImageURL,
            createdAt: nil,
            modifiedAt: nil
        )
    }

}
