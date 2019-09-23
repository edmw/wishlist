struct ListPageFormContext: Encodable {

    var data: ListPageFormData?

    var invalidTitle: Bool
    var invalidVisibility: Bool
    var duplicateName: Bool

    init(from data: ListPageFormData?) {
        self.data = data

        invalidTitle = false
        invalidVisibility = false
        duplicateName = false
    }

}
