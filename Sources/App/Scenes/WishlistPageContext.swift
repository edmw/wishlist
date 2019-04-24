import Foundation

struct WishlistPageContext: Encodable {

    var ownerID: ID?
    var listID: ID?

    var ownerName: String
    var listName: String

    var items: [ItemContext]?

    var userID: ID?

    var userName: String?
    var userFirstName: String?

    var identification: ID?

    init(
        for list: List,
        of owner: User,
        with items: [ItemContext]? = nil,
        user: User? = nil,
        identification: Identification
    ) {
        self.ownerID = ID(owner.id)
        self.listID = ID(list.id)

        self.ownerName = owner.nickName ?? owner.firstName
        self.listName = list.name

        self.items = items

        self.userID = ID(user?.id)

        self.userName = user?.name
        self.userFirstName = user?.firstName

        self.identification = ID(identification)
    }

}
