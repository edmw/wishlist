// MARK: FavoriteRepresentation

public struct FavoriteRepresentation: Encodable, Equatable {

    public let list: ListRepresentation

    init(
        list: ListRepresentation
    ) {
        self.list = list
    }

    init(_ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.init(
            list: ListRepresentation(list, ownerName: ownerName, itemsCount: itemsCount)
        )
    }

}
