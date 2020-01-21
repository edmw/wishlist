import DomainModel
import Library

// MARK: FavoriteRepresentation

extension FavoriteRepresentation {

    internal init(_ list: List, ownerName: String? = nil, itemsCount: Int? = nil) {
        self.init(
            list: ListRepresentation(list, ownerName: ownerName, itemsCount: itemsCount)
        )
    }

}
