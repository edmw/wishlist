import Domain

import Vapor
import Fluent

extension ListController {

    // MARK: Save

    struct ListSaveResult {
        let user: UserRepresentation
        let list: ListRepresentation?
    }
    final class ListSaveOutcome: Outcome<ListSaveResult, ListEditingContext> {}

    /// Saves a list for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new or
    /// updated list and creates a new list or updates an existing list if given.
    ///
    /// This function handles thrown `EntityError`s by constructing a page context while adding
    /// the corresponding error flags.
    func save(
        from request: Request,
        for userid: UserID,
        this listid: ListID? = nil
    ) throws
        -> EventLoopFuture<ListSaveOutcome>
    {
        let userListsActor = self.userListsActor
        return try request.content
            .decode(ListEditingData.self)
            .flatMap { data in
                let values = ListValues(from: data)

                return try userListsActor
                    .createOrUpdateList(
                        .specification(userBy: userid, listBy: listid, from: values),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        let context = ListEditingContext(with: data)
                        return .success(
                            with: .init(user: result.user, list: result.list),
                            context: context
                        )
                    }
                    .catchMap(UserListsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, data: data)
                    }
            }
    }

    private func handleErrorOnSave(
        with error: UserListsActorError,
        data: ListEditingData
    ) throws
        -> ListSaveOutcome
    {
        if case let UserListsActorError
            .validationError(user, list, error) = error
        {
            var context = ListEditingContext(with: data)
            switch error {
            case .validationFailed(let properties, _):
                context.invalidTitle = properties.contains(\ListValues.title)
                context.invalidVisibility = properties.contains(\ListValues.visibility)
            case .uniquenessViolated:
                // a list with the given name already exists
                context.duplicateName = true
            }
            return .failure(with: .init(user: user, list: list), context: context, has: error)
        }
        else {
            throw error
        }
    }

}
