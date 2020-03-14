import Domain

import Foundation

struct LegalNoticePageContext: PageContext {

    var actions = PageActions()

    let userID: ID?

    init(for user: UserRepresentation?) {
        self.userID = ID(user?.id)
    }

}
