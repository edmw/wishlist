import Vapor
import Fluent

extension ListController {

    // MARK: Save

    enum SaveResult {
        case success(list: List)
        case failure(context: ListPageContext)
    }

    /// Saves a list for the specified user from the request’s data.
    /// Validates the data contained in the request, checks the constraints required for a new or
    /// updated list and creates a new list or updates an existing list if given.
    ///
    /// This function handles thrown `EntityError`s by rendering the form page again while adding
    /// the corresponding error flags to the page context.
    static func save(
        from request: Request,
        for user: User,
        this list: List? = nil
    ) throws
        -> EventLoopFuture<SaveResult>
    {
        return try request.content
            .decode(ListPageFormData.self)
            .flatMap { formdata in
                let context = ListPageContext(for: user, with: list, from: formdata)

                return request.future()
                    .flatMap {
                        return try save(
                            from: formdata,
                            for: user,
                            this: list,
                            on: request
                        )
                        .map { list in .success(list: list) }
                    }
                    .catchMap(EntityError<List>.self) {
                        try handleSaveOnError($0, with: context)
                    }
            }
    }

    private static func handleSaveOnError(
        _ error: EntityError<List>,
        with contextIn: ListPageContext
    ) throws
        -> SaveResult
    {
        var context = contextIn
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
        return .failure(context: context)
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
        -> EventLoopFuture<List>
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
                return listRepository.save(list: entity)
            }
    }

}
