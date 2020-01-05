import Domain

import Foundation

struct PrivacyPolicyPageContext: Encodable {

    let userID: ID?

    init(for user: UserRepresentation?) {
        self.userID = ID(user?.id)
    }

}
