import Domain

import Vapor

// MARK: VaporEmailSendingProvider

/// Adapter for the domain layers `EmailSendingProvider` to be used with Vapor.
///
/// This delegates the work to the web app‘s email sending framework.
struct VaporEmailSendingProvider: EmailSendingProvider {

    let request: Request

    init(on request: Request) {
        self.request = request
    }

    // func dispatchSendInvitationEmail -> implemented in file `Scenes/Invitations/InvitationEmail`

}
