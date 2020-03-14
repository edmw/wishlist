import Domain

// MARK: ProfileEditingData

/// This structures holds all the input given by the user into the profile form.
/// In contrast to `UserRepresentation` and `UserData` this contains only editable properties.
struct ProfileEditingData: Codable {

    let inputNickName: String

    init() {
        self.inputNickName = ""
    }

    init(from user: UserRepresentation) {
        self.inputNickName = user.nickName ?? ""
    }

}
