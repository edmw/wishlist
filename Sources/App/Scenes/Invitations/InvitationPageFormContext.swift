struct InvitationPageFormContext: PageFormContext {

    var data: InvitationPageFormData?

    var invalidEmail: Bool

    init(from data: InvitationPageFormData?) {
        self.data = data

        invalidEmail = false
    }

}
