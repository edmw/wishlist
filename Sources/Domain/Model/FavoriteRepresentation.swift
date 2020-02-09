// MARK: FavoriteRepresentation

public struct FavoriteRepresentation: Encodable, Equatable {

    public let list: ListRepresentation

    init(_ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.list = ListRepresentation(list, ownerName: ownerName, itemsCount: itemsCount)
    }

}
