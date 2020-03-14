import Domain

import Vapor

extension Page {

    static func lists(with result: GetLists.Result) throws -> Self {
        return try .init(
            templateName: "User/Lists",
            context: ListsPageContext.builder
                .forUser(result.user)
                .withLists(result.lists)
                .build()
        )
    }

}
