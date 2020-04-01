import Domain

import Vapor

final class ListController: AuthenticatableController,
    ListParameterAcceptor,
    RouteCollection
{
    let userListsActor: UserListsActor

    init(_ userListsActor: UserListsActor) {
        self.userListsActor = userListsActor
    }

    // MARK: - VIEWS

    /// Renders a form view for creating or updating a list.
    /// This is only accessible for an authenticated user.
    private func renderFormView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try listID(on: request)

        return try userListsActor
            .requestListEditing(
                .specification(userBy: userid, listBy: listid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .listEditing(with: result), on: request)
            }
    }

    /// Renders a view to confirm the deletion of a list.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderDeleteView(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        return try userListsActor
            .requestListDeletion(
                .specification(userBy: userid, listBy: listid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .listDeletion(with: result), on: request)
                    .encode(for: request)
            }
            .catchMap(UserListsActorError.self) { _ in
                // Tries to redirect back to the lists page.
                Controller.redirect(for: userid, to: "lists", on: request)
            }
    }

    // MARK: - EXTRA

    private func export(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        return try userListsActor
            .exportList(
                .specification(userBy: userid, listBy: listid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let name = result.name
                let json = result.json
                let headers = HTTPHeaders([
                    ("Content-Disposition", "attachment; filename=\(name).json")
                ])
                return json.encode(status: .ok, headers: headers, for: request)
            }
    }

    // MARK: - Routing

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

        // list creation

        router.get("user", ID.parameter, "lists", "create",
            use: self.renderFormView
        )
        router.post("user", ID.parameter, "lists",
            use: self.create
        )

        // list handling

        router.get("user", ID.parameter, "list", ID.parameter, "edit",
            use: self.renderFormView
        )
        router.get("user", ID.parameter, "list", ID.parameter, "delete",
            use: self.renderDeleteView
        )
        router.post("user", ID.parameter, "list", ID.parameter,
            use: self.dispatch
        )
        router.get("user", ID.parameter, "list", ID.parameter, "export",
            use: self.export
        )
    }

}
