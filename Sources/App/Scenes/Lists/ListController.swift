import Vapor
import Fluent

final class ListController: ProtectedController,
    ListParameterAcceptor,
    RouteCollection
{

    let listRepository: ListRepository
    let itemRepository: ItemRepository

    init(_ listRepository: ListRepository, _ itemRepository: ItemRepository) {
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    // MARK: - VIEWS

    /// Renders a form view for creating or updating a list.
    /// This is only accessible for an authenticated user.
    private func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        if request.parameters.values.isEmpty {
            // render form to create new list
            let context = ListPageContext(for: user)
            return try Controller.renderView("User/List", with: context, on: request)
        }
        else {
            // render form to edit list
            return try requireList(on: request, for: user).flatMap { list in
                let data = ListPageFormData(from: list)
                let context = ListPageContext(
                    for: user,
                    with: list,
                    from: data
                )
                return try Controller.renderView("User/List", with: context, on: request)
            }
            // malformed parameter errors yield internal server errors
        }
    }

    /// Renders a view to confirm the deletion of a list.
    /// This is only accessible for an authenticated user who owns the affected item.
    private func renderDeleteView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user).flatMap { list in
            let context = ListPageContext(for: user, with: list)
            return try Controller.renderView("User/ListDeletion", with: context, on: request)
        }
    }

    // MARK: - CRUD

    // Creates a list with the given data.
    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
            .caseSuccess { list in
                return try request.future(list)
                    .emitEvent("created for \(user)", on: request)
                    .logMessage("created for \(user)", on: request)
                    .transform(to: self.success(for: user, on: request))
            }
            .caseFailure { context in try self.failure(on: request, with: context) }
    }

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try self.save(from: request, for: user, this: list)
                    .caseSuccess { list in
                        return request.future(list)
                            .logMessage("updated for \(user)", on: request)
                            .transform(to: self.success(for: user, on: request))
                    }
                .caseFailure { context in try self.failure(on: request, with: context) }
            }
    }

    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .deleteModel(on: request)
            .emitEvent("deleted for \(user)", on: request)
            .logMessage("deleted for \(user)", on: request)
            .transform(to: success(for: user, on: request))
    }

    // MARK: - EXTRA

    private func exportFilename(for list: List) -> String {
        let listtitle = list.title.slugify()
        let datestamp = Date().exportDatestamp()
        var components = ["wishlist"]
        if let listtitle = listtitle {
            components.append(listtitle)
        }
        components.append(datestamp)
        return components.joined(separator: "-")
    }

    private func export(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try self.itemRepository
                    .all(for: list)
                    .flatMap(to: Response.self, { items in
                        let filename = self.exportFilename(for: list)
                        let headers = HTTPHeaders([
                            ("Content-Disposition", "attachment; filename=\(filename).json")
                        ])
                        return ListData(list, items)
                            .encode(status: .ok, headers: headers, for: request)
                    })
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
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
        with context: ListPageContext
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try Controller.renderView("User/List", with: context, on: request)
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

// MARK: -

extension Date {

    fileprivate func exportDatestamp() -> String {
        return DateFormatter.ExportDatestampFormatter.string(from: self)
    }

}

extension DateFormatter {

    fileprivate static let ExportDatestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

}
