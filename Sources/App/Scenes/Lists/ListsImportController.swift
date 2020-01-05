import Domain

import Vapor
import Fluent

struct ListFileUpload: Content {
    var file: Data
}

final class ListsImportController: AuthenticatableController, RouteCollection {

    let userListsActor: UserListsActor

    init(_ userListsActor: UserListsActor) {
        self.userListsActor = userListsActor
    }

    // MARK: - VIEWS

    private func renderImportView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try self.userListsActor
            .requestListImport(
                .specification(userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try ListsPageContextBuilder()
                    .forUserRepresentation(result.user)
                    .build()
                return try Controller.renderView("User/ListsImport", with: context, on: request)
            }
    }

    // MARK: - EXTRA

    private func importList(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)

        return try request.content.decode(ListFileUpload.self)
            .flatMap { upload in
                guard let json = String(data: upload.file, encoding: .utf8) else {
                    throw Abort(.badRequest)
                }
                return try self.userListsActor
                    .importList(
                        .specification(userBy: userid, json: json),
                        .boundaries(
                            worker: request.eventLoop,
                            imageStore: VaporImageStoreProvider(on: request)
                        )
                    )
                    .flatMap { result in self.success(for: result.user, on: request) }
            }
            .catchFlatMap { error in
                if case let UserListsActorError.importErrorForUser(user) = error {
                    let context = try ListsPageContextBuilder()
                        .forUserRepresentation(user)
                        .build()
                    return try self.failure(on: request, with: context)
                }
                throw error
            }
    }

    // MARK: - RESULT

    /// Returns a success response on an import request.
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
        on request: Request,
        with context: ListsPageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.renderView("User/ListsImportError", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "lists", "import",
            use: self.renderImportView
        )
        router.post("user", ID.parameter, "lists", "import",
            use: self.importList
        )
    }

}
