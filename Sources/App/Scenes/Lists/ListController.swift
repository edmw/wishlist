import Vapor
import Fluent

final class ListController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    /// Renders a form view for creating or updating a list.
    /// This is only accessible for an authenticated user.
    private static func renderFormView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        if request.parameters.values.isEmpty {
            // render form to create new list
            let context = ListPageContext(for: user)
            return try renderView("User/List", with: context, on: request)
        }
        else {
            // render form to edit list
            return try requireList(on: request, for: user)
                .flatMap { list in
                    let data = ListPageFormData(from: list)
                    let context = ListPageContext(
                        for: user,
                        with: list,
                        from: data
                    )
                    return try renderView("User/List", with: context, on: request)
                }
            // malformed parameter errors yield internal server errors
        }
    }

    /// Renders a view to confirm the deletion of a list.
    /// This is only accessible for an authenticated user who owns the affected item.
    private static func renderDeleteView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                let context = ListPageContext(for: user, with: list)
                return try renderView("User/ListDeletion", with: context, on: request)
            }
    }

    // MARK: - CRUD

    // Creates a list with the given data.
    private static func create(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
    }

    private static func update(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try save(from: request, for: user, this: list)
            }
    }

    private static func delete(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .delete(on: request)
            .emit(
                event: "deleted for \(user)",
                on: request
            )
            .transform(to: success(for: user, on: request))
    }

    /// Saves a list for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new or
    /// updated list and creates a new list or updates an existing list if given.
    ///
    /// This function handles thrown `EntityError`s by rendering the form page again while adding
    /// the corresponding error flags to the page context.
    private static func save(
        from request: Request,
        for user: User,
        this list: List? = nil
    ) throws
        -> Future<Response>
    {
        return try request.content
            .decode(ListPageFormData.self)
            .flatMap { formdata in
                var context = ListPageContext(for: user, with: list, from: formdata)

                return request.future()
                    .flatMap {
                        return try save(
                            from: formdata,
                            for: user,
                            this: list,
                            on: request
                        )
                    }
                    .catchFlatMap(EntityError<List>.self) { error in
                        switch error {
                        case .validationFailed(let properties, _):
                            context.form.invalidTitle = properties.contains(\List.title)
                            context.form.invalidVisibility = properties.contains(\List.visibility)
                        case .uniquenessViolated:
                            // a list with the given name already exists
                            context.form.duplicateName = true
                        default:
                            throw error
                        }
                        return try failure(on: request, with: context)
                    }
            }
    }

    /// Saves a list for the specified user from the given form data.
    /// Validates the data, checks the constraints required for a new or updated list and creates
    /// a new list or updates an existing list if given.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private static func save(
        from formdata: ListPageFormData,
        for user: User,
        this list: List? = nil,
        on request: Request
    ) throws
        -> Future<Response>
    {
        let listRepository = try request.make(ListRepository.self)

        return try ListData(from: formdata)
            .validate(for: user, this: list, using: listRepository)
            .flatMap { data in
                // save list
                let entity: List
                if let list = list {
                    // update list
                    entity = list
                    try entity.update(for: user, from: data)
                    entity.modifiedAt = Date()
                }
                else {
                    // create list
                    entity = try List(for: user, from: data)
                }
                return try listRepository
                    .save(list: entity)
                    .emit(
                        event: "created for \(user)",
                        on: request,
                        when: { $0.modifiedAt == $0.createdAt }
                    )
                    .transform(to: success(for: user, on: request))
            }
    }

    // MARK: - EXTRA

    private static func exportFilename(for list: List) -> String {
        let listtitle = list.title.slugify()
        let datestamp = Date().exportDatestamp()
        var components = ["wishlist"]
        if let listtitle = listtitle {
            components.append(listtitle)
        }
        components.append(datestamp)
        return components.joined(separator: "-")
    }

    private static func export(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try request.make(ItemRepository.self)
                    .all(for: list)
                    .flatMap(to: Response.self, { items in
                        let filename = exportFilename(for: list)
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
        with context: ListPageContext
    ) throws -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/List", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
                switch method {
                case .PUT:
                    return try update(on: request)
                case .DELETE:
                    return try delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // list creation

        router.get("user", ID.parameter, "lists", "create",
            use: ListController.renderFormView
        )
        router.post("user", ID.parameter, "lists",
            use: ListController.create
        )

        // list handling

        router.get("user", ID.parameter, "list", ID.parameter, "edit",
            use: ListController.renderFormView
        )
        router.get("user", ID.parameter, "list", ID.parameter, "delete",
            use: ListController.renderDeleteView
        )
        router.post("user", ID.parameter, "list", ID.parameter,
            use: ListController.dispatch
        )
        router.get("user", ID.parameter, "list", ID.parameter, "export",
            use: ListController.export
        )
    }

    // MARK: -

    /// Stores the given list data into a new list.
    /// Data must pass properties validation and constraints check.
    static func store(
        _ listdata: ListData,
        for user: User,
        on request: Request
    ) throws -> Future<List> {
        let listRepository = try request.make(ListRepository.self)

        return try listdata.validate(for: user, using: listRepository)
            .flatMap { listdata in
                // create list
                let list = try List(for: user, from: listdata)
                return listRepository
                    .save(list: list)
                    .flatMap { list in
                        guard let itemsdata = listdata.items else {
                            return request.future(list)
                        }
                        var futureItems = [Future<Item>]()
                        // store items
                        for itemdata in itemsdata {
                            futureItems.append(
                                try ItemController.store(itemdata, for: list, on: request)
                            )
                        }
                        return futureItems.flatten(on: request)
                            .transform(to: list)
                    }
            }
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
