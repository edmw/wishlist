struct ListPageFormContext: Encodable {

    var data: ListPageFormData?

    var invalidName: Bool
    var invalidVisibility: Bool
    var duplicateName: Bool

    init(from data: ListPageFormData?) {
        self.data = data

        invalidName = false
        invalidVisibility = false
        duplicateName = false
    }

}
