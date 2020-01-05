import Foundation

// MARK: FavoriteRepresentation

public struct FavoriteRepresentation: Encodable, Equatable {

    public internal(set) var list: ListRepresentation

    internal init(_ list: List) {
        self.list = ListRepresentation(list)
    }

}
