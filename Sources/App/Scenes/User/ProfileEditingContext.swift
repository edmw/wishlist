import Domain

// MARK: ProfileEditingContext

struct ProfileEditingContext: Codable {

    var data: ProfileEditingData?

    var invalidNickName: Bool = false
    var duplicateNickName: Bool = false

    static var empty: ProfileEditingContext { return .init(with: nil) }

    init(with data: ProfileEditingData?) {
        self.data = data
    }

    init(from user: UserRepresentation) {
        self.init(with: ProfileEditingData(from: user))
    }

}
