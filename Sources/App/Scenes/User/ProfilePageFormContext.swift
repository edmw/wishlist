struct ProfilePageFormContext: Encodable {

    var data: ProfilePageFormData?

    var invalidNickName: Bool
    var duplicateNickName: Bool

    init(from data: ProfilePageFormData?) {
        self.data = data

        invalidNickName = false
        duplicateNickName = false
    }

}
