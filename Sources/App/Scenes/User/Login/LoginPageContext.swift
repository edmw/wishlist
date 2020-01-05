import Domain

import Foundation

struct LoginPageContext: Encodable {

    var authenticationParametersQuery: String?

    var invitationCode: InvitationCode?

}
