import Domain

import Vapor
import Fluent

extension ItemController {

    // MARK: Save

    final class ItemSaveOutcome: Outcome<CreateOrUpdateItem.Result, ItemPageContext> {}

    /// Saves an item for the specified user and list from the request’s data.
    /// Validates the data contained in the request and
    /// creates a new item or updates an existing item if given.
    ///
    /// This function handles thrown `EntityError`s by constructing a page context while adding
    /// the corresponding error flags.
    func save(
        from request: Request,
        for userid: UserID,
        and listid: ListID,
        this itemid: ItemID? = nil
    ) throws
        -> EventLoopFuture<ItemSaveOutcome>
    {
        let userItemsActor = self.userItemsActor
        return try request.content
            .decode(ItemPageFormData.self)
            .flatMap { formdata in
                let data = ItemValues(from: formdata)

                var contextBuilder = ItemPageContextBuilder().withFormData(formdata)

                return try userItemsActor
                    .createOrUpdateItem(
                        .specification(userBy: userid, listBy: listid, itemBy: itemid, from: data),
                        .boundaries(
                            worker: request.eventLoop,
                            imageStore: VaporImageStoreProvider(on: request)
                        )
                    )
                    .map { result in
                        contextBuilder = contextBuilder.with(result.user, result.list, result.item)
                        return try .success(with: result, context: contextBuilder.build())
                    }
                    .catchMap(UserItemsActorError.self) { error in
                        if case let UserItemsActorError
                            .validationError(user, list, item, error) = error
                        {
                            contextBuilder = contextBuilder.with(user, list, item)
                            return try self.handleErrorOnSave(error, with: contextBuilder.build())
                        }
                        throw error
                    }
            }
    }

    private func handleErrorOnSave(
        _ error: ValuesError<ItemValues>,
        with contextIn: ItemPageContext
    ) throws
        -> ItemSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidTitle = properties.contains(\ItemValues.title)
            context.form.invalidText = properties.contains(\ItemValues.text)
            context.form.invalidURL = properties.contains(\ItemValues.url)
            context.form.invalidImageURL = properties.contains(\ItemValues.imageURL)
        default:
            throw error
        }
        return .failure(with: error, context: context)
    }

}
