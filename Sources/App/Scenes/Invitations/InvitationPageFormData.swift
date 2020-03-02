import Domain

import Vapor

/// This structures holds all the input given by the user into the invitation form.
/// In contrast to `InvitationRepresentation` and `InvitationData` this contains only
/// editable properties.
struct InvitationPageFormData: Content {

    let inputEmail: String
    let inputSendEmail: Bool?

    init() {
        self.inputEmail = ""
        self.inputSendEmail = false
    }

}

extension InvitationValues {

    init(from formdata: InvitationPageFormData) {
        self.init(
            code: nil,
            status: nil,
            email: formdata.inputEmail,
            sentAt: nil,
            createdAt: nil
        )
    }

}
