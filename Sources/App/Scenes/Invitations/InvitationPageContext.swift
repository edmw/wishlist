import Domain

import Foundation

// MARK: InvitationPageContext

struct InvitationPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

    var userID: ID?

    var invitation: InvitationContext?

    var form: InvitationEditingContext

    var sendSuccess: Bool = false

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with invitation: InvitationRepresentation? = nil,
        from editingContext: InvitationEditingContext? = nil
    ) {
        self.userID = ID(user.id)

        self.invitation = InvitationContext(invitation)

        self.form = editingContext ?? .empty
    }

}
