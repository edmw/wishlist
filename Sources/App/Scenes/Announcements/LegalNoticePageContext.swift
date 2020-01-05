import Domain

import Foundation

struct LegalNoticePageContext: Encodable {

    let userID: ID?

    init(for user: UserRepresentation?) {
        self.userID = ID(user?.id)
    }

}
