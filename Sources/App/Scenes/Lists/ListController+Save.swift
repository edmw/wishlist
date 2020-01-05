import Domain

import Vapor
import Fluent

extension ListController {

    // MARK: Save

    final class ListSaveOutcome: Outcome<CreateOrUpdateList.Result, ListPageContext> {}

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
            .decode(ListPageFormData.self)
            .flatMap { formdata in
                let data = ListValues(from: formdata)

                var contextBuilder = ListPageContextBuilder().withFormData(formdata)

                return try userListsActor
                    .createOrUpdateList(
                        .specification(userBy: userid, listBy: listid, from: data),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        contextBuilder = contextBuilder.with(result.user, result.list)
                        return try .success(with: result, context: contextBuilder.build())
                    }
                    .catchMap(UserListsActorError.self) { error in
                        if case let UserListsActorError
                            .validationError(user, list, error) = error
                        {
                            contextBuilder = contextBuilder.with(user, list)
                            return try self.handleErrorOnSave(error, with: contextBuilder.build())
                        }
                        throw error
                    }
            }
    }

    private func handleErrorOnSave(
        _ error: ValuesError<ListValues>,
        with contextIn: ListPageContext
    ) throws
        -> ListSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidTitle = properties.contains(\ListValues.title)
            context.form.invalidVisibility = properties.contains(\ListValues.visibility)
        case .uniquenessViolated:
            // a list with the given name already exists
            context.form.duplicateName = true
        }
        return .failure(with: error, context: context)
    }

}
