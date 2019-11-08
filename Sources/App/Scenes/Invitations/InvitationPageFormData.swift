import Vapor

/// This structures holds all the input given by the user into the invitation form.
/// In contrast to `InvitationData` this contains only editable properties.
struct InvitationPageFormData: Content {
    // swiftlint:disable discouraged_optional_boolean

    let inputEmail: String
    let inputSendEmail: Bool?

    init() {
        self.inputEmail = ""
        self.inputSendEmail = false
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
