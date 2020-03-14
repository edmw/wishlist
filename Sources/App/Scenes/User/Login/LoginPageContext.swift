import Domain

import Foundation

struct LoginPageContext: PageContext {

    var actions = PageActions()

    var authenticationParametersQuery: String?

    var invitationCode: InvitationCode?

}
