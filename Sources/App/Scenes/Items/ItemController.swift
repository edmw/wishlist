import Vapor
import Fluent

final class ItemController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    /// Renders a form view for creating or updating an item.
    /// This is only accessible for an authenticated user who owns the selected list.
    private static func renderFormView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                if request.parameters.values.isEmpty {
                    // render form to create new item
                    let context = ItemPageContext(for: user, and: list)
                    return try renderView("User/Item", with: context, on: request)
                }
                else {
                    let itemID = try request.parameters.next(ID.self)
                    // render form to edit item
                    return try request.make(ItemRepository.self)
                        .findWithReservation(by: itemID.uuid, in: list)
                        .unwrap(or: Abort(.noContent))
                        .flatMap { item, reservation in
                            let data = ItemPageFormData(from: item)
                            let context = ItemPageContext(
                                for: user,
                                and: list,
                                with: item,
                                and: reservation,
                                from: data
                            )
                            return try renderView("User/Item", with: context, on: request)
                        }
                    // malformed parameter errors yield internal server errors
                }
            }
    }

    /// Renders a view to confirm the deletion of an item.
    /// This is only accessible for an authenticated user who owns the affected item.
    private static func renderDeleteView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        let context = ItemPageContext(for: user, and: list, with: item)
                        return try renderView("User/ItemDeletion", with: context, on: request)
                    }
            }
    }

    // MARK: - CRUD

    // Creates an item with the given data. The item will be part of the specified list.
    // The list must belong to the authenticated user.
    private static func create(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try save(from: request, for: user, and: list)
            }
    }

    // Updates the specified item with the given data. The item must be part of the specified list.
    // The list must belong to the authenticated user.
    private static func update(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        return try save(from: request, for: user, and: list, this: item)
                    }
            }
    }

    // Deletes the specified item. The item must be part of the specified list. The list must
    // belong to the authenticated user.
    // Performs a cleanup for the item to be deleted which includes removal of attached images.
    // Items with existing reservations can not be deleted and result in a 409 conflict error.
    private static func delete(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                let itemID = try request.parameters.next(ID.self)
                return try request.make(ItemRepository.self)
                    .findWithReservation(by: itemID.uuid, in: list)
                    .unwrap(or: Abort(.badRequest))
                    .map { item, reservation in
                        guard reservation == nil else {
                            throw Abort(.conflict)
                        }
                        return item
                    }
                    .cleanup(on: request)
                    .delete(on: request)
                    .emit(
                        event: "deleted for \(user)",
                        on: request
                    )
                    .transform(to: success(for: user, and: list, on: request))
            }
    }

    /// Saves an item for the specified user and list from the request’s data.
    /// Validates the data contained in the request and
    /// creates a new item or updates an existing item if given.
    ///
    /// This function handles thrown `EntityError`s by rendering the form page again while adding
    /// the corresponding error flags to the page context.
    private static func save(
        from request: Request,
        for user: User,
        and list: List,
        this item: Item? = nil
    ) throws
        -> Future<Response>
    {
        return try request.content
            .decode(ItemPageFormData.self)
            .flatMap { formdata in
                var context = ItemPageContext(for: user, and: list, with: item, from: formdata)

                return request.future()
                    .flatMap {_ in
                        return try save(
                            from: formdata, for: user, and: list, this: item, on: request
                        )
                    }
                    .catchFlatMap(EntityError<Item>.self) { error in
                        switch error {
                        case .validationFailed(let properties, _):
                            context.form.invalidTitle = properties.contains(\Item.title)
                            context.form.invalidText = properties.contains(\Item.text)
                            context.form.invalidURL = properties.contains(\Item.url)
                            context.form.invalidImageURL = properties.contains(\Item.imageURL)
                        default:
                            throw error
                        }
                        return try failure(on: request, with: context)
                    }
            }
    }

    /// Saves an item for the specified user from the given form data.
    /// Validates the data, checks the constraints required for a new or updated item and creates
    /// a new item or updates an existing item if given.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private static func save(
        from formdata: ItemPageFormData,
        for user: User,
        and list: List,
        this item: Item? = nil,
        on request: Request
    ) throws
        -> Future<Response>
    {
        let itemRepository = try request.make(ItemRepository.self)

        return try ItemData(from: formdata)
            .validate(for: list, this: item, using: itemRepository)
            .flatMap { data in
                // save item
                let entity: Item
                if let item = item {
                    // update item
                    entity = item
                    try entity.update(for: list, from: data)
                    entity.modifiedAt = Date()
                }
                else {
                    // create item
                    entity = try Item(for: list, from: data)
                }
                return try itemRepository
                    .save(item: entity)
                    .setup(on: request)
                    .emit(
                        event: "created for \(user)",
                        on: request,
                        when: { $0.modifiedAt == $0.createdAt }
                    )
                    .transform(to: success(for: user, and: list, on: request))
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(
        for user: User,
        and list: List,
        on request: Request
    ) -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: redirect(for: user, and: list, to: "items", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private static func failure(
        on request: Request,
        with context: ItemPageContext
    ) throws -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/Item", with: context, on: request)
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

        // item creation

        router.get("user", ID.parameter, "list", ID.parameter, "items", "create",
            use: ItemController.renderFormView
        )
        router.post("user", ID.parameter, "list", ID.parameter, "items",
            use: ItemController.create
        )

        // item handling

        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "edit",
                use: ItemController.renderFormView
        )
        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "delete",
                use: ItemController.renderDeleteView
        )
        router.post(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter,
                use: ItemController.dispatch
        )
    }

    // MARK: -

    /// Stores the given item data into a new item.
    /// Data must pass properties validation and constraints check.
    static func store(
        _ itemdata: ItemData,
        for list: List,
        on request: Request
    ) throws -> Future<Item> {
        let itemRepository = try request.make(ItemRepository.self)

        return try itemdata.validate(for: list, using: itemRepository)
            .flatMap { itemdata in
                // create item
                let item = try Item(for: list, from: itemdata)
                return itemRepository
                    .save(item: item)
                    .setup(on: request)
                    .transform(to: item)
            }
    }

}

// MARK: -

extension Future where Expectation == Item {

    fileprivate func setup(on request: Request) -> Future<Item> {
        return self.flatMap(to: Item.self) { item in
            guard let imageURL = item.imageURL else {
                return request.future(item)
            }
            return try item.uploadImage(from: imageURL, on: request)
                .flatMap { localImageURL in
                    guard let localImageURL = localImageURL else {
                        return request.future(item)
                    }
                    item.localImageURL = localImageURL
                    return try request.make(ItemRepository.self)
                        .save(item: item)
                }
                .catchFlatMap { error in
                    request.logger?.application.error(
                        "Error while setting up item: \(error)"
                    )
                    return request.future(item)
                }
        }
    }

    fileprivate func cleanup(on request: Request) -> Future<Item> {
        return self.flatMap(to: Item.self) { item in
            try item.removeImages(on: request)
            return request.future(item)
        }
    }

}
