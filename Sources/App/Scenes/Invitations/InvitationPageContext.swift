import Foundation

struct InvitationPageContext: Encodable {

    var userID: ID?

    var invitation: InvitationContext?

    var form: InvitationPageFormContext

    init(
        for user: User,
        with invitation: Invitation? = nil,
        from data: InvitationPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        if let invitation = invitation {
            self.invitation = InvitationContext(for: invitation)
        }
        else {
            self.invitation = nil
        }

        self.form = InvitationPageFormContext(from: data)
    }

}
