// MARK: FavoriteRepresentation

public struct FavoriteRepresentation: Representation, Encodable, Equatable {

    public let list: ListRepresentation

    public let notificationsEnabled: Bool

    init(_ favorite: Favorite, _ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.notificationsEnabled = favorite.notifications.isEmpty == false
        self.list = ListRepresentation(list, ownerName: ownerName, itemsCount: itemsCount)
    }

}
