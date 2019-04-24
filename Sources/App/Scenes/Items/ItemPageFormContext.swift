import Vapor

struct ItemPageFormContext: Encodable {

    var data: ItemPageFormData?

    var invalidName: Bool
    var invalidText: Bool
    var invalidURL: Bool
    var invalidImageURL: Bool

    init(from data: ItemPageFormData?) {
        self.data = data

        invalidName = false
        invalidText = false
        invalidURL = false
        invalidImageURL = false
    }

}
