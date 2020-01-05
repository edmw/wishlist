import Library
import Domain

import Vapor

/// This structures holds all the input given by the user into the item form.
/// In contrast to `ItemRepresentation` and `ItemData` this contains only editable properties.
struct ItemPageFormData: Content {

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

    init(from formdata: ItemPageFormData) {
        self.init(
            title: formdata.inputTitle,
            text: formdata.inputText,
            preference: formdata.inputPreference,
            url: formdata.inputURL,
            imageURL: formdata.inputImageURL,
            createdAt: nil,
            modifiedAt: nil
        )
    }

}
