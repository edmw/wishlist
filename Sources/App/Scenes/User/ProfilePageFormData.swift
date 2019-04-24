import Vapor

/// This structures holds all the input given by the user into the profile form.
/// In contrast to `UserData` this contains only editable properties.
struct ProfilePageFormData: Content {

    let inputNickName: String

    init() {
        self.inputNickName = ""
    }

    init(from user: User) {
        self.inputNickName = user.nickName ?? ""
    }

}

extension UserData {

    mutating func update(from formdata: ProfilePageFormData) {
        self.nickName = formdata.inputNickName
    }

}
