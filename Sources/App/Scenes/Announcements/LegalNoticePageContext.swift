import Domain

import Foundation

struct LegalNoticePageContext: PageContext {

    let userID: ID?

    init(for user: UserRepresentation?) {
        self.userID = ID(user?.id)
    }

}
