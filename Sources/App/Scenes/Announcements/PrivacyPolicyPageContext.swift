import Domain

import Foundation

struct PrivacyPolicyPageContext: PageContext {

    let userID: ID?

    init(for user: UserRepresentation?) {
        self.userID = ID(user?.id)
    }

}
