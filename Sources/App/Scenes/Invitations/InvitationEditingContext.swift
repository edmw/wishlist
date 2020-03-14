import Domain

// MARK: InvitationEditingContext

struct InvitationEditingContext: Codable {

    var data: InvitationEditingData?

    var invalidEmail: Bool = false

    static var empty: InvitationEditingContext { .init(with: nil) }

    init(with data: InvitationEditingData?) {
        self.data = data
    }

    init() {
        self.init(with: InvitationEditingData())
    }

}
