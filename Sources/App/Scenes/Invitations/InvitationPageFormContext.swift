import Vapor

struct InvitationPageFormContext: Encodable {

    var data: InvitationPageFormData?

    var invalidEmail: Bool

    init(from data: InvitationPageFormData?) {
        self.data = data

        invalidEmail = false
    }

}
