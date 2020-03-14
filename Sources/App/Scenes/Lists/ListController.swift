import Domain

import Vapor
import Fluent

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

    // MARK: - CRUD

    // Creates a list with the given data.
    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try save(from: request, for: userid)
            .caseSuccess { result in self.success(for: result.user, on: request) }
            .caseFailure { result, context in
                try self.failure(for: result.user, and: result.list, with: context, on: request)
            }
    }

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        return try save(from: request, for: userid, this: listid)
            .caseSuccess { result in self.success(for: result.user, on: request) }
            .caseFailure { result, context in
                try self.failure(for: result.user, and: result.list, with: context, on: request)
            }
    }

    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        return try userListsActor
            .deleteList(
                .specification(userBy: userid, listBy: listid),
                .boundaries(
                    worker: request.eventLoop,
                    imageStore: VaporImageStoreProvider(on: request)
                )
            )
            .flatMap { result in self.success(for: result.user, on: request) }
            .transformError(
                when: UserListsActorError.listHasReservedItems,
                then: Abort(.conflict)
            )
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

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for user: UserRepresentation, on request: Request)
        -> EventLoopFuture<Response>
    {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(for: user.id, to: "lists", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        for user: UserRepresentation,
        and list: ListRepresentation?,
        with editingContext: ListEditingContext,
        on request: Request
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.render(
            page: .listEditing(with: user, and: list, editingContext: editingContext),
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
