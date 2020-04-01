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

    /// Renders a view to manage an item.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderManageView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)

        return try userItemsActor
            .requestItemManagement(
                .specification(userBy: userid, listBy: listid, itemBy: itemid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .itemManagement(with: result), on: request)
                    .encode(for: request)
            }
            .catchFlatMap(UserItemsActorError.self) { _ in
                // Tries to redirect back to the items page.
                Controller.redirect(for: userid, and: listid, to: "items", on: request)
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

    // MARK: - Routing

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
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "manage",
                use: self.renderManageView
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
