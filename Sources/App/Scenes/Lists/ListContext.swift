import Vapor

import Foundation

struct ListContext: Encodable {

    var id: ID?

    var title: String
    var visibility: String
    var createdAt: Date
    var modifiedAt: Date

    var ownerName: String?

    var itemsCount: Int?

    init(for list: List) {
        self.id = ID(list.id)

        self.title = list.title ??? "�"
        self.visibility = String(describing: list.visibility)
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt
    }

}
