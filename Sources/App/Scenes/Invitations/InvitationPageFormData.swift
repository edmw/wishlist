import Vapor

/// This structures holds all the input given by the user into the invitation form.
/// In contrast to `InvitationData` this contains only editable properties.
struct InvitationPageFormData: Content {

    let inputEmail: String

    init() {
        self.inputEmail = ""
    }

}

extension InvitationData {

    init(from formdata: InvitationPageFormData) {
        self.code = nil
        self.status = nil
        self.email = formdata.inputEmail
        self.sentAt = nil
        self.createdAt = nil
    }

}
