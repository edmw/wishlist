import Domain

import Foundation

struct InvitationPageContext: PageContext, AutoPageContextBuilder {

    var userID: ID?

    var invitation: InvitationContext?

    var form: InvitationPageFormContext

    var sendSuccess: Bool = false

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with invitation: InvitationRepresentation? = nil,
        from formData: InvitationPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        self.invitation = InvitationContext(invitation)

        self.form = InvitationPageFormContext(from: formData)
    }

}
