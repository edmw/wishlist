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

                return try userItemsActor
                    .createOrUpdateItem(
                        .specification(userBy: userid, listBy: listid, itemBy: itemid, from: data),
                        .boundaries(
                            worker: request.eventLoop,
                            imageStore: VaporImageStoreProvider(on: request)
                        )
                    )
                    .map { result in
                        return try self.handleSuccessOnSave(with: result, formdata: formdata)
                    }
                    .catchMap(UserItemsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, formdata: formdata)
                    }
            }
    }

    private func handleSuccessOnSave(
        with result: CreateOrUpdateItem.Result,
        formdata: ItemPageFormData
    ) throws -> ItemSaveOutcome {
        let user = result.user
        let list = result.list
        let item = result.item
        let context = try ItemPageContext.builder
            .withFormData(formdata)
            .forUser(user)
            .forList(list)
            .withItem(item)
            .build()
        return .success(with: result, context: context)
    }

    private func handleErrorOnSave(
        with error: UserItemsActorError,
        formdata: ItemPageFormData
    ) throws -> ItemSaveOutcome {
        if case let UserItemsActorError
            .validationError(user, list, item, error) = error
        {
            var context = try ItemPageContext.builder
                .withFormData(formdata)
                .forUser(user)
                .forList(list)
                .withItem(item)
                .build()
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
        else {
            throw error
        }
    }

}
