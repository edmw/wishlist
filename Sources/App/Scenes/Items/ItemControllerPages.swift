import Domain

import Vapor

extension Page {

    static func itemEditing(
        with user: UserRepresentation,
        and list: ListRepresentation,
        and item: ItemRepresentation?,
        editingContext: ItemEditingContext
    ) throws -> Self {
        if let item = item {
            // update existing item
            return try .init(
                templateName: "User/Item",
                context: ItemPageContext.builder
                    .forUser(user)
                    .forList(list)
                    .withItem(item)
                    .withEditing(editingContext)
                    .setAction("form", .put("user", user.id, "list", list.id, "item", item.id))
                    .build()
            )
        }
        else {
            // create new item
            return try .init(
                templateName: "User/Item",
                context: ItemPageContext.builder
                    .forUser(user)
                    .forList(list)
                    .withEditing(editingContext)
                    .setAction("form", .post("user", user.id, "list", list.id, "items"))
                    .build()
            )
        }
    }

    static func itemEditing(with result: RequestItemEditing.Result) throws -> Self {
        let user = result.user
        let list = result.list
        let item = result.item
        let editingcontext = ItemEditingContext(from: item)
        return try itemEditing(with: user, and: list, and: item, editingContext: editingcontext)
    }

    static func itemDeletion(with result: RequestItemDeletion.Result) throws -> Self {
        let user = result.user
        let list = result.list
        let item = result.item
        return try .init(
            templateName: "User/ItemDeletion",
            context: ItemPageContext.builder
                .forUser(user)
                .forList(list)
                .withItem(item)
                .setAction("form", .delete("user", user.id, "list", list.id, "item", item.id))
                .build()
        )
    }

    static func itemMovement(with result: RequestItemMovement.Result) throws -> Self {
        let user = result.user
        let list = result.list
        let item = result.item
        var pageContext = try ItemPageContext.builder
            .forUser(user)
            .forList(list)
            .withItem(item)
            .setAction("form", .patch("user", user.id, "list", list.id, "item", item.id))
            .build()
        pageContext.userLists = result.lists.map { ListContext($0) }
        return .init(
            templateName: "User/ItemMove",
            context: pageContext
        )
    }

    static func itemReceiving(with result: RequestItemReceiving.Result) throws -> Self {
        let user = result.user
        let list = result.list
        let item = result.item
        return try .init(
            templateName: "User/ItemReceiving",
            context: ItemPageContext.builder
                .forUser(user)
                .forList(list)
                .withItem(item)
                .setAction("form", .get("user", user.id, "list", list.id, "item", item.id))
                .build()
        )
    }

}
