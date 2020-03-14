import Domain

// MARK: InvitationEditingData

/// This structures holds all the input given by the user into the invitation form.
/// In contrast to `InvitationRepresentation` and `InvitationData` this contains only
/// editable properties.
struct InvitationEditingData: Codable {

    let inputEmail: String
    let inputSendEmail: Bool?

    init() {
        self.inputEmail = ""
        self.inputSendEmail = false
    }

}

extension InvitationValues {

    init(from data: InvitationEditingData) {
        self.init(
            code: nil,
            status: nil,
            email: data.inputEmail,
            sentAt: nil,
            createdAt: nil
        )
    }

}
