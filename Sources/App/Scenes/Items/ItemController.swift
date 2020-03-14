import Domain

import Vapor

final class ItemController: AuthenticatableController,
    ItemParameterAcceptor,
    ListParameterAcceptor,
    RouteCollection
{
    let userItemsActor: UserItemsActor

    init(_ userItemsActor: UserItemsActor) {
        self.userItemsActor = userItemsActor
    }

    // MARK: - VIEWS

    /// Renders a form view for creating or updating an item.
    /// This is only accessible for an authenticated user who owns the selected list.
    private func renderFormView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try itemID(on: request)

        return try userItemsActor
            .requestItemEditing(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .itemEditing(with: result), on: request)
            }
    }

    /// Renders a view to confirm the deletion of an item.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderDeleteView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)

        return try userItemsActor
            .requestItemDeletion(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .itemDeletion(with: result), on: request)
                    .encode(for: request)
            }
            .catchFlatMap(UserItemsActorError.self) { _ in
                // Tries to redirect back to the items page.
                Controller.redirect(for: userid, and: listid, to: "items", on: request)
            }
    }

    /// Renders a view to select the target list to move an item to.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderMoveView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        return try userItemsActor
            .requestItemMovement(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .itemMovement(with: result), on: request)
                    .encode(for: request)
            }
            .catchFlatMap(UserItemsActorError.self) { _ in
                // Tries to redirect back to the list page.
                Controller.redirect(for: userid, and: listid, to: "items", on: request)
            }
    }

    /// Renders a view to confirm marking an item as received.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderReceiveView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        return try userItemsActor
            .requestItemReceiving(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .itemReceiving(with: result), on: request)
                    .encode(for: request)
            }
            .catchFlatMap(UserItemsActorError.self) { _ in
                // Tries to redirect back to the list page.
                Controller.redirect(for: userid, and: listid, to: "items", on: request)
            }
    }

    // MARK: - CRUD

    // Creates an item with the given data. The item will be part of the specified list.
    // The list must belong to the authenticated user.
    private func create(on request: Request) throws -> EventLoopFuture<Response> {
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
    private func update(on request: Request) throws -> EventLoopFuture<Response> {
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
    private func patch(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)

        let userItemsActor = self.userItemsActor
        return try request.content.decode(Patch.self)
            .flatMap { patch in
                switch patch.key {
                case "listID":
                    // patches the list of the specified item
                    guard let id = ID(patch.value)
                        else {
                            throw Abort(.badRequest)
                        }
                    return try userItemsActor
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
                default:
                    throw Abort(.badRequest)
                }
            }

    }

    // Deletes the specified item. The item must be part of the specified list. The list must
    // belong to the authenticated user.
    // Performs a cleanup for the item to be deleted which includes removal of attached images.
    // Items with existing reservations can not be deleted and result in a 409 conflict error.
    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
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
                when: UserItemsActorError.itemIsReserved,
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

    // MARK: -

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try self.update(on: request)
                case .PATCH:
                    return try self.patch(on: request)
                case .DELETE:
                    return try self.delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // item creation

        router.get("user", ID.parameter, "list", ID.parameter, "items", "create",
            use: self.renderFormView
        )
        router.post("user", ID.parameter, "list", ID.parameter, "items",
            use: self.create
        )

        // item handling

        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "edit",
                use: self.renderFormView
        )
        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "delete",
                use: self.renderDeleteView
        )
        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "move",
                use: self.renderMoveView
        )
        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "receive",
                use: self.renderReceiveView
        )
        router.post(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter,
                use: self.dispatch
        )
    }

}
