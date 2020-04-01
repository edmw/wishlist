import Domain

import Vapor

extension ListController {

    // MARK: - CRUD

    // Creates a list with the given data.
    func create(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try save(from: request, for: userid)
            .caseSuccess { result in self.success(for: result.user, on: request) }
            .caseFailure { result, context in
                try self.failure(for: result.user, and: result.list, with: context, on: request)
            }
    }

    func update(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        return try save(from: request, for: userid, this: listid)
            .caseSuccess { result in self.success(for: result.user, on: request) }
            .caseFailure { result, context in
                try self.failure(for: result.user, and: result.list, with: context, on: request)
            }
    }

    func delete(on request: Request) throws -> EventLoopFuture<Response> {
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

}
