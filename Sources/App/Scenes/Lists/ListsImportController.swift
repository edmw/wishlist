import Vapor
import Fluent

struct ListFileUpload: Content {
    var file: Data
}

final class ListsImportController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    private static func renderImportView(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        let context = ListsPageContext(for: user)
        return try renderView("User/ListsImport", with: context, on: request)
    }

    // MARK: - EXTRA

    private static func importList(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try request.content.decode(ListFileUpload.self)
            .flatMap { upload in
                guard let json = String(data: upload.file, encoding: .utf8) else {
                    throw Abort(.badRequest)
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let data = try decoder.decode(ListData.self, from: json)

                return try request.make(ListRepository.self)
                    .available(title: data.title, for: user)
                    .unwrap(
                        or: Abort(.badRequest, reason: "no available list name")
                    )
                    .flatMap { title in
                        return try ListController
                            .store(data.with(title: title), for: user, on: request)
                            .emitEvent("created for \(user)", on: request)
                            .transform(to: success(for: user, on: request))
                    }
            }
            .catchFlatMap { error in
                if let abortError = error as? AbortError, abortError.status == .badRequest {
                    request.logger?.application.debug("Import abort error: \(abortError)")
                }
                else if let entityError = error as? EntityError<List> {
                    request.logger?.application.debug("Import entity error: \(entityError)")
                }
                else {
                    throw error
                }
                return try failure(on: request, with: ListsPageContext(for: user))
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on an import request.
    /// Not implemented yet: REST response
    private static func success(for user: User, on request: Request) -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: redirect(for: user, to: "lists", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private static func failure(
        on request: Request,
        with context: ListsPageContext
    ) throws
        -> Future<Response>
    {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/ListsImportError", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "lists", "import",
            use: ListsImportController.renderImportView
        )
        router.post("user", ID.parameter, "lists", "import",
            use: ListsImportController.importList
        )
    }

}
