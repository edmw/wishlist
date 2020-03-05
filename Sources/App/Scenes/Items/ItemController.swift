import Domain

import Vapor
import Fluent

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
                var contextBuilder = ItemPageContext.builder
                    .forUser(result.user)
                    .forList(result.list)
                if let item = result.item {
                    contextBuilder = contextBuilder
                        .withItem(item)
                        .withFormData(ItemPageFormData(from: item))
                }
                let context = try contextBuilder.build()
                return try Controller.renderView("User/Item", with: context, on: request)
            }
    }

    /// Renders a view to confirm the deletion of an item.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderDeleteView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)

        return try userItemsActor
            .requestItemDeletion(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try ItemPageContext.builder
                    .forUser(result.user)
                    .forList(result.list)
                    .withItem(result.item)
                    .build()
                return try Controller.renderView("User/ItemDeletion", with: context, on: request)
            }
    }

    /// Renders a view to select the target list to move an item to.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderMoveView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        return try userItemsActor
            .requestItemMovement(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                var context = try ItemPageContext.builder
                    .forUser(result.user)
                    .forList(result.list)
                    .withItem(result.item)
                    .build()

// TODO
//                let moveAction = PageAction.patch(
//                    "user",
//                    result.user.id,
//                    "list",
//                    result.list.id,
//                    "item",
//                    result.item.id
//                )
//                context.link("move", to: moveAction)

                context.userLists = result.lists.map { ListContext($0) }
                return try Controller.renderView("User/ItemMove", with: context, on: request)
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
            .caseFailure { context in try self.failure(on: request, with: context) }
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
            .caseFailure { context in try self.failure(on: request, with: context) }
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
        on request: Request,
        with context: ItemPageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.renderView("User/Item", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try self.update(on: request)
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
        router.post(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter,
                use: self.dispatch
        )
    }

}
