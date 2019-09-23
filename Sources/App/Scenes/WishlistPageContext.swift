import Foundation

struct WishlistPageContext: Encodable {

    var ownerID: ID?
    var listID: ID?

    var ownerName: String
    var listTitle: String

    var items: [ItemContext]?

    var userID: ID?

    var userFullName: String?
    var userFirstName: String?

    var userFavorsList: Bool

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

        self.ownerName = owner.displayName
        self.listTitle = list.title

        self.items = items

        self.userID = ID(user?.id)

        self.userFullName = user?.fullName
        self.userFirstName = user?.firstName
        self.userFavorsList = false

        self.identification = ID(identification)
    }

}
