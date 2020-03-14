import Domain

import Foundation

// MARK: WishlistPageContext

struct WishlistPageContext: PageContext, AutoPageContextBuilder {

    var actions = PageActions()

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

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for list: ListRepresentation,
        of owner: UserRepresentation,
        with items: [ItemRepresentation]? = nil,
        user: UserRepresentation? = nil,
        isFavorite: Bool = false,
        identification: Identification
    ) {
        self.ownerID = ID(owner.id)
        self.listID = ID(list.id)

        self.ownerName = owner.displayName
        self.listTitle = list.title

        self.items = items?.map { item in ItemContext(item) }

        self.userID = ID(user?.id)

        self.userFullName = user?.fullName
        self.userFirstName = user?.firstName
        self.userFavorsList = isFavorite

        self.identification = ID(identification)
    }

}
