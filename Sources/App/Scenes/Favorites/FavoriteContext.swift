import Vapor

import Foundation

struct FavoriteContext: Encodable {

    var list: ListContext

    init(for list: List) {
        self.list = ListContext(for: list)
    }

}
