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

                return try userListsActor
                    .createOrUpdateList(
                        .specification(userBy: userid, listBy: listid, from: data),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        return try self.handleSuccessOnSave(with: result, formdata: formdata)
                    }
                    .catchMap(UserListsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, formdata: formdata)
                    }
            }
    }

    private func handleSuccessOnSave(
        with result: CreateOrUpdateList.Result,
        formdata: ListPageFormData
    ) throws -> ListSaveOutcome {
        let user = result.user
        let list = result.list
        let context = try ListPageContextBuilder()
            .withFormData(formdata)
            .forUser(user)
            .withList(list)
            .build()
        return .success(with: result, context: context)
    }

    private func handleErrorOnSave(
        with error: UserListsActorError,
        formdata: ListPageFormData
    ) throws
        -> ListSaveOutcome
    {
        if case let UserListsActorError
            .validationError(user, list, error) = error
        {
            var context = try ListPageContextBuilder()
                .withFormData(formdata)
                .forUser(user)
                .withList(list)
                .build()
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
        else {
            throw error
        }
    }

}
