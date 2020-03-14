import Domain

import Vapor

extension Page {

    static func listEditing(
        with user: UserRepresentation,
        and list: ListRepresentation?,
        editingContext: ListEditingContext
    ) throws -> Self {
        if let list = list {
            // update existing list
            return try .init(
                templateName: "User/List",
                context: ListPageContext.builder
                    .forUser(user)
                    .withList(list)
                    .withEditing(editingContext)
                    .setAction("form", .put("user", user.id, "list", list.id))
                    .build()
            )
        }
        else {
            // create new list
            return try .init(
                templateName: "User/List",
                context: ListPageContext.builder
                    .forUser(user)
                    .withEditing(editingContext)
                    .setAction("form", .post("user", user.id, "lists"))
                    .build()
            )
        }
    }

    static func listEditing(with result: RequestListEditing.Result) throws -> Self {
        let user = result.user
        let list = result.list
        let editingcontext = ListEditingContext(from: list)
        return try listEditing(with: user, and: list, editingContext: editingcontext)
    }

    static func listDeletion(with result: RequestListDeletion.Result) throws -> Self {
        let user = result.user
        let list = result.list
        return try .init(
            templateName: "User/ListDeletion",
            context: ListPageContext.builder
                .forUser(user)
                .withList(list)
                .setAction("form", .delete("user", user.id, "list", list.id))
                .build()
        )
    }

}
