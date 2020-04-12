import Domain

import Vapor

extension ItemController {

    // MARK: Save

    struct ItemSaveResult {
        let user: UserRepresentation
        let list: ListRepresentation
        let item: ItemRepresentation?
    }
    final class ItemSaveOutcome: Outcome<ItemSaveResult, ItemEditingContext> {}

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
            .decode(ItemEditingData.self)
            .flatMap { data in
                let values = ItemValues(from: data)

                return try userItemsActor
                    .createOrUpdateItem(
                        .specification(
                            userBy: userid,
                            listBy: listid,
                            itemBy: itemid,
                            from: values
                        ),
                        .boundaries(
                            worker: request.eventLoop,
                            imageStore: VaporImageStoreProvider(on: request),
                            notificationSending: VaporNotificationSendingProvider(on: request)
                        )
                    )
                    .map { result in
                        let context = ItemEditingContext(with: data)
                        return .success(
                            with: .init(user: result.user, list: result.list, item: result.item),
                            context: context
                        )
                    }
                    .catchMap(UserItemsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, data: data)
                    }
            }
    }

    private func handleErrorOnSave(
        with error: UserItemsActorError,
        data: ItemEditingData
    ) throws -> ItemSaveOutcome {
        if case let UserItemsActorError
            .validationError(user, list, item, error) = error
        {
            var context = ItemEditingContext(with: data)
            switch error {
            case .validationFailed(let properties, _):
                context.invalidTitle = properties.contains(\ItemValues.title)
                context.invalidText = properties.contains(\ItemValues.text)
                context.invalidURL = properties.contains(\ItemValues.url)
                context.invalidImageURL = properties.contains(\ItemValues.imageURL)
            default:
                throw error
            }
            return .failure(
                with: .init(user: user, list: list, item: item),
                context: context,
                has: error
            )
        }
        else {
            throw error
        }
    }

}
