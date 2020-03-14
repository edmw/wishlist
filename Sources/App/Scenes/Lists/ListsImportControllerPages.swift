import Domain

import Vapor

extension Page {

    static func listsImporting(with result: RequestListImportFromJSON.Result) throws
        -> Self
    {
        let user = result.user
        return try .init(
            templateName: "User/ListsImport",
            context: ListsPageContext.builder
                .forUser(user)
                .setAction("form", .post("user", user.id, "lists", "import"))
                .build()
        )
    }

}
