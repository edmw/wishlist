import Foundation

// MARK: FavoriteRepresentation

public struct FavoriteRepresentation: Encodable, Equatable {

    public let list: ListRepresentation

    public init(
        list: ListRepresentation
    ) {
        self.list = list
    }

}
