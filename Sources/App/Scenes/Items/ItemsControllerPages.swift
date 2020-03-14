import Domain

import Vapor

extension Page {

    static func items(with result: GetItems.Result) throws -> Self {
        return try .init(
            templateName: "User/Items",
            context: ItemsPageContext.builder
                .forUser(result.user)
                .forList(result.list)
                .withItems(result.items)
                .build()
        )
    }

}
