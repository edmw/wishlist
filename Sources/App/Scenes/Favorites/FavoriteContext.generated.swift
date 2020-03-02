// sourcery:inline:FavoriteRepresentation.AutoRepresentationContext

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: FavoriteContext

/// Type which is used in a render context of a page.
/// Encodes a `FavoriteRepresentation` while converting typed IDs to `ID`.
struct FavoriteContext: Encodable {

    let favorite: FavoriteRepresentation

    let list: ListContext

    enum Keys: String, CodingKey {
        case list
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(list, forKey: .list)
    }

    init(_ favorite: FavoriteRepresentation) {
        self.favorite = favorite
        self.list = ListContext(favorite.list)
    }

    init?(_ favorite: FavoriteRepresentation?) {
        guard let favorite = favorite else {
            return nil
        }
        self.init(favorite)
    }

}
// sourcery:end
