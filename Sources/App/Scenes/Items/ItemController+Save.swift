import Vapor
import Fluent

extension ItemController {

    // MARK: Save

    final class ItemSaveOutcome: Outcome<Item, ItemPageContext> {}

    /// Saves an item for the specified user and list from the request’s data.
    /// Validates the data contained in the request and
    /// creates a new item or updates an existing item if given.
    ///
    /// This function handles thrown `EntityError`s by constructing a page context while adding
    /// the corresponding error flags.
    static func save(
        from request: Request,
        for user: User,
        and list: List,
        this item: Item? = nil
    ) throws
        -> EventLoopFuture<ItemSaveOutcome>
    {
        return try request.content
            .decode(ItemPageFormData.self)
            .flatMap { formdata in
                let context = try ItemPageContextBuilder()
                    .forUser(user)
                    .forList(list)
                    .withItem(item)
                    .withFormData(formdata)
                    .build()

                return request.future()
                    .flatMap { _ in
                        return try save(
                            from: formdata, for: user, and: list, this: item, on: request
                        )
                        .map { item in .success(with: item, context: context) }
                    }
                    .catchMap(EntityError<Item>.self) {
                        try handleErrorOnSave($0, with: context)
                    }
            }
    }

    private static func handleErrorOnSave(
        _ error: EntityError<Item>,
        with contextIn: ItemPageContext
    ) throws
        -> ItemSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidTitle = properties.contains(\Item.title)
            context.form.invalidText = properties.contains(\Item.text)
            context.form.invalidURL = properties.contains(\Item.url)
            context.form.invalidImageURL = properties.contains(\Item.imageURL)
        default:
            throw error
        }
        return .failure(with: error, context: context)
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
        -> EventLoopFuture<Item>
    {
        let itemRepository = try request.make(ItemRepository.self)

        return try ItemData(from: formdata)
            .validate(for: list, this: item, using: itemRepository, on: request)
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
                return itemRepository.save(item: entity)
            }
    }

}
