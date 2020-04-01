import Domain

import Vapor

extension ItemController {

    // MARK: - CRUD

    // Creates an item with the given data. The item will be part of the specified list.
    // The list must belong to the authenticated user.
    func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        return try save(from: request, for: userid, and: listid)
            .caseSuccess { result, _ in
                self.success(for: result.user, and: result.list, on: request)
            }
            .caseFailure { result, context in
                try self.failure(
                    for: result.user,
                    and: result.list,
                    and: result.item,
                    with: context,
                    on: request
                )
            }
    }

    // Updates the specified item with the given data. The item must be part of the specified list.
    // The list must belong to the authenticated user.
    func update(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try itemID(on: request)

        return try save(from: request, for: userid, and: listid, this: itemid)
            .caseSuccess { result, _ in
                self.success(for: result.user, and: result.list, on: request)
            }
            .caseFailure { result, context in
                try self.failure(
                    for: result.user,
                    and: result.list,
                    and: result.item,
                    with: context,
                    on: request
                )
            }
    }

    private struct Patch: Decodable {
        let key: String
        let value: String
    }

    // Patches the specified item with the given data. The item must be part of the specified list.
    // The list must belong to the authenticated user.
    // This PATCH request is a little off a standard ReST PATCH requests, because it accepts only
    // one key and value pair and updates one value only.
    func patch(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try request.content.decode(Patch.self)
            .flatMap { patch in
                switch patch.key {
                case "listID":
                    return try self.patch(listID: patch.value, on: request, userBy: userid)
                case "received":
                    return try self.patch(received: patch.value, on: request, userBy: userid)
                case "archived":
                    return try self.patch(archived: patch.value, on: request, userBy: userid)
                default:
                    throw Abort(.badRequest)
                }
            }

    }

    private func patch(listID value: String, on request: Request, userBy userid: UserID) throws
        -> EventLoopFuture<Response>
    {
        guard let id = ID(value)
            else {
                throw Abort(.badRequest)
            }
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        // patches the list of the specified item
        return try self.userItemsActor
            .moveItem(
                .specification(
                    userBy: userid,
                    listBy: listid,
                    itemBy: itemid,
                    targetListID: ListID(id)
                ),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                self.success(for: result.user, and: result.list, on: request)
            }
    }

    private func patch(received value: String, on request: Request, userBy userid: UserID) throws
        -> EventLoopFuture<Response>
    {
        guard let received = value.bool else {
            throw Abort(.badRequest)
        }
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        if received == true {
            return try self.userItemsActor
                .receiveItem(
                    .specification(userBy: userid, listBy: listid, itemBy: itemid),
                    .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                self.success(for: result.user, and: result.list, on: request)
            }
        }
        else {
            throw Abort(.badRequest)
        }
    }

    private func patch(archived value: String, on request: Request, userBy userid: UserID) throws
        -> EventLoopFuture<Response>
    {
        guard let archived = value.bool else {
            throw Abort(.badRequest)
        }
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        if archived == true {
            return try self.userItemsActor
                .archiveItem(
                    .specification(userBy: userid, listBy: listid, itemBy: itemid),
                    .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                self.success(for: result.user, and: result.list, on: request)
            }
        }
        else {
            return try self.userItemsActor
                .unarchiveItem(
                    .specification(userBy: userid, listBy: listid, itemBy: itemid),
                    .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                self.success(for: result.user, and: result.list, on: request)
            }
        }
    }

    // Deletes the specified item. The item must be part of the specified list. The list must
    // belong to the authenticated user.
    // Performs a cleanup for the item to be deleted which includes removal of attached images.
    // Items with existing reservations can not be deleted and result in a 409 conflict error.
    func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)

        return try userItemsActor
            .deleteItem(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(
                    worker: request.eventLoop,
                    imageStore: VaporImageStoreProvider(on: request)
                )
            )
            .flatMap { result in self.success(for: result.user, and: result.list, on: request) }
            .transformError(
                when: UserItemsActorError.itemNotDeletable,
                then: Abort(.conflict)
            )
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(
        for user: UserRepresentation,
        and list: ListRepresentation,
        on request: Request
    ) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(for: user.id, and: list.id, to: "items", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        for user: UserRepresentation,
        and list: ListRepresentation,
        and item: ItemRepresentation?,
        with editingContext: ItemEditingContext,
        on request: Request
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.render(
            page: .itemEditing(with: user, and: list, and: item, editingContext: editingContext),
            on: request
        )
        .encode(for: request)
    }

}
