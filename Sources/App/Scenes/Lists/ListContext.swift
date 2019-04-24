import Vapor

import Foundation

struct ListContext: Encodable {

    var id: ID?

    var name: String
    var visibility: String
    var createdAt: Date
    var modifiedAt: Date

    var itemsCount: Int?

    init(for list: List) {
        self.id = ID(list.id)

        self.name = list.name ??? "�"
        self.visibility = String(describing: list.visibility)
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt
    }

}
