import Vapor
import Fluent

final class ItemController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    /// Renders a form view for creating or updating an item.
    /// This is only accessible for an authenticated user who owns the selected list.
    private static func renderFormView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user).flatMap { list in
            let contextBuilder = ItemPageContextBuilder().forUser(user).forList(list)

            if request.parameters.values.isEmpty {
                // render form to create new item
                let context = try contextBuilder.build()
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
                        let context = try contextBuilder
                            .withItem(item)
                            .withReservation(reservation)
                            .withFormData(data)
                            .build()
                        return try renderView("User/Item", with: context, on: request)
                    }
                // malformed parameter errors yield internal server errors
            }
        }
    }

    /// Renders a view to confirm the deletion of an item.
    /// This is only accessible for an authenticated user who owns the affected item.
    private static func renderDeleteView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user).flatMap { list in
            return try requireItem(on: request, for: list).flatMap { item in
                let context = try ItemPageContextBuilder()
                    .forUser(user)
                    .forList(list)
                    .withItem(item)
                    .build()
                return try renderView("User/ItemDeletion", with: context, on: request)
            }
        }
    }

    /// Renders a view to select the target list to move an item to.
    /// This is only accessible for an authenticated user who owns the affected item.
    private static func renderMoveView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user).flatMap { list in
            return try requireItem(on: request, for: list).flatMap { item in
                let listContextsBuilder = ListContextsBuilder()
                    .forUser(user)
                    .filter { $0.id != list.id }
                return try listContextsBuilder.build(on: request)
                    .flatMap { listsContexts in
                        var context = try ItemPageContextBuilder()
                            .forUser(user)
                            .forList(list)
                            .withItem(item)
                            .build()
                        context.userLists = listsContexts
                        return try renderView("User/ItemMove", with: context, on: request)
                    }
            }
        }
    }

    // MARK: - CRUD

    // Creates an item with the given data. The item will be part of the specified list.
    // The list must belong to the authenticated user.
    private static func create(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try save(from: request, for: user, and: list)
                    .flatMap { result in
                        switch result {
                        case let .success(item, list):
                            return try request.future(item)
                                .setup(on: request)
                                .emitEvent("created for \(user)", on: request)
                                .logMessage("created for \(user)", on: request)
                                .transform(to: success(for: user, and: list, on: request))
                        case .failure(let context):
                            return try failure(on: request, with: context)
                        }
                    }
            }
    }

    // Updates the specified item with the given data. The item must be part of the specified list.
    // The list must belong to the authenticated user.
    private static func update(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        return try save(from: request, for: user, and: list, this: item)
                            .flatMap { result in
                                switch result {
                                case let .success(item, list):
                                    return request.future(item)
                                        .setup(on: request)
                                        .logMessage("updated for \(user)", on: request)
                                        .transform(to: success(for: user, and: list, on: request))
                                case .failure(let context):
                                    return try failure(on: request, with: context)
                                }
                            }
                    }
            }
    }

    // Deletes the specified item. The item must be part of the specified list. The list must
    // belong to the authenticated user.
    // Performs a cleanup for the item to be deleted which includes removal of attached images.
    // Items with existing reservations can not be deleted and result in a 409 conflict error.
    private static func delete(on request: Request) throws -> EventLoopFuture<Response> {
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
                    .deleteModel(on: request)
                    .emitEvent("deleted for \(user)", on: request)
                    .logMessage("deleted for \(user)", on: request)
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
    ) -> EventLoopFuture<Response> {
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
    ) throws -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/Item", with: context, on: request)
            .flatMap { view in
                return try view.encode(for: request)
            }
    }

    // MARK: -

    private static func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
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
        router.get(
            "user", ID.parameter, "list", ID.parameter, "item", ID.parameter, "move",
                use: ItemController.renderMoveView
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
    ) throws -> EventLoopFuture<Item> {
        let itemRepository = try request.make(ItemRepository.self)

        return try itemdata.validate(for: list, using: itemRepository, on: request)
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

extension EventLoopFuture where Expectation == Item {

    fileprivate func setup(on request: Request) -> EventLoopFuture<Item> {
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

    fileprivate func cleanup(on request: Request) -> EventLoopFuture<Item> {
        return self.flatMap(to: Item.self) { item in
            try item.removeImages(on: request)
            return request.future(item)
        }
    }

}
