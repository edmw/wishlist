import Domain

import Foundation

/// Type which is used in a render context of a page. The reason why `FavoriteRepresentation` is not
/// used directly is, the list property has to be converted from `ListRepresentation` to
/// `ListContext`.
struct FavoriteContext: Encodable {

    let list: ListContext?

    init(_ favorite: FavoriteRepresentation) {
        self.list = ListContext(favorite.list)
    }

    init?(_ favorite: FavoriteRepresentation?) {
        guard let favorite = favorite else {
            return nil
        }
        self.init(favorite)
    }

}
