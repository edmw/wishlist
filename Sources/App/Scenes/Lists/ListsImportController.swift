import Vapor
import Fluent

struct ListFileUpload: Content {
    var file: Data
}

final class ListsImportController: ProtectedController, RouteCollection {

    let listRepository: ListRepository
    let itemRepository: ItemRepository

    init(_ listRepository: ListRepository, _ itemRepository: ItemRepository) {
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    // MARK: - VIEWS

    private func renderImportView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let context = ListsPageContext(for: user)
        return try Controller.renderView("User/ListsImport", with: context, on: request)
    }

    // MARK: - EXTRA

    private func importList(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try request.content.decode(ListFileUpload.self)
            .flatMap { upload in
                guard let json = String(data: upload.file, encoding: .utf8) else {
                    throw Abort(.badRequest)
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let data = try decoder.decode(ListData.self, from: json)

                return try self.listRepository
                    .available(title: data.title, for: user)
                    .unwrap(
                        or: Abort(.badRequest, reason: "no available list name")
                    )
                    .flatMap { title in
                        return try self.store(data.with(title: title), for: user, on: request)
                            .emitEvent("created for \(user)", on: request)
                            .logMessage("created for \(user)", on: request)
                            .transform(to: self.success(for: user, on: request))
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
                return try self.failure(on: request, with: ListsPageContext(for: user))
            }
    }

    /// Stores the given list data into a new list.
    /// Data must pass properties validation and constraints check.
    private func store(
        _ listdata: ListData,
        for user: User,
        on request: Request
    ) throws -> EventLoopFuture<List> {
        return try listdata.validate(for: user, using: listRepository)
            .flatMap { listdata in
                // create list
                let list = try List(for: user, from: listdata)
                return self.listRepository
                    .save(list: list)
                    .flatMap { list in
                        guard let itemsdata = listdata.items else {
                            return request.future(list)
                        }
                        var futureItems = [Future<Item>]()
                        // store items
                        for itemdata in itemsdata {
                            futureItems.append(
                                try self.store(itemdata, for: list, on: request)
                            )
                        }
                        return futureItems.flatten(on: request)
                            .transform(to: list)
                    }
            }
    }

    /// Stores the given item data into a new item.
    /// Data must pass properties validation and constraints check.
    private func store(
        _ itemdata: ItemData,
        for list: List,
        on request: Request
    ) throws -> EventLoopFuture<Item> {
        return try itemdata.validate(for: list, using: itemRepository, on: request)
            .flatMap { itemdata in
                // create item
                let item = try Item(for: list, from: itemdata)
                return self.itemRepository
                    .save(item: item)
                    .setup(on: request, in: self.itemRepository)
                    .transform(to: item)
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on an import request.
    /// Not implemented yet: REST response
    private func success(for user: User, on request: Request) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(for: user, to: "lists", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private func failure(
        on request: Request,
        with context: ListsPageContext
    ) throws
        -> EventLoopFuture<Response>
    {
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
