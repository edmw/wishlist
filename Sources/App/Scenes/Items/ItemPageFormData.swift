import Vapor

/// This structures holds all the input given by the user into the item form.
/// In contrast to `ItemData` this contains only editable properties.
struct ItemPageFormData: Content {

    let inputName: String
    let inputText: String
    let inputPreference: Item.Preference
    let inputURL: String
    let inputImageURL: String

    init() {
        self.inputName = ""
        self.inputText = ""
        self.inputPreference = .normal
        self.inputURL = ""
        self.inputImageURL = ""
    }

    init(from item: Item) {
        self.inputName = item.name
        self.inputText = item.text
        self.inputPreference = item.preference
        self.inputURL = item.url ??? ""
        self.inputImageURL = item.imageURL ??? ""
    }

}

extension ItemData {

    init(from formdata: ItemPageFormData) {
        self.name = formdata.inputName
        self.text = formdata.inputText
        self.preference = formdata.inputPreference
        self.url = formdata.inputURL
        self.imageURL = formdata.inputImageURL
        self.createdAt = nil
        self.modifiedAt = nil
    }

}
