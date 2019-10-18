import Foundation

struct LegalNoticePageContext: Encodable {

    let userID: ID?

    init(for user: User?) {
        self.userID = ID(user?.id)
    }

}
