import Vapor

final class ProfileController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        let invitations = try InvitationsController.buildContexts(for: user, on: request)

        return invitations.flatMap { invitations in
            let context = ProfilePageContext(for: user, invitations: invitations)
            return try renderView("User/Profile", with: context, on: request)
        }
    }

    /// Renders a form view for creating or updating a list.
    /// This is only accessible for an authenticated user.
    private static func renderFormView(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        let data = ProfilePageFormData(from: user)
        let context = ProfilePageContext(
            for: user,
            from: data
        )
        return try renderView("User/ProfileForm", with: context, on: request)
    }

    // MARK: - CRUD

    private static func update(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try save(from: request, for: user)
    }

    /// Saves a profile for the specified user from the request’s data.
    /// Validates the data contained in the request and updates the user.
    private static func save(
        from request: Request,
        for user: User
    ) throws
        -> Future<Response>
    {
        return try request.content
            .decode(ProfilePageFormData.self)
            .flatMap { formdata in
                var context = ProfilePageContext(for: user, from: formdata)

                return request.future()
                    .flatMap {
                        return try save(from: formdata, for: user, on: request)
                    }
                    .catchFlatMap(EntityError<User>.self) { error in
                        switch error {
                        case .validationFailed(let properties, _):
                            context.form.invalidNickName = properties.contains(\User.nickName)
                        case .uniquenessViolated:
                            // an user with the given nickname already exists
                            context.form.duplicateNickName = true
                        default:
                            throw error
                        }
                        return try failure(on: request, with: context)
                    }
            }
    }

    /// Saves an user from the given form data.
    /// Validates the data, checks the constraints required for an updated user and updates an
    /// existing user.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private static func save(
        from formdata: ProfilePageFormData,
        for user: User,
        on request: Request
    ) throws
        -> Future<Response>
    {
        let userRepository = try request.make(UserRepository.self)

        var userData = UserData(user)
        userData.update(from: formdata)
        return try userData
            .validate(using: userRepository)
            .flatMap { data in
                // save user

                try user.update(from: data)

                return userRepository
                    .save(user: user)
                    .transform(to: success(for: user, on: request))
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for user: User, on request: Request) -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: redirect(for: user, to: "", on: request)
            )
        }
    }

    /// Returns a failure response on a CRUD request.
    /// Not implemented yet: REST response
    private static func failure(
        on request: Request,
        with context: ProfilePageContext
    ) throws -> Future<Response> {
        // to add real REST support, check the accept header for json and output a json response
        return try renderView("User/ProfileForm", with: context, on: request)
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
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // profile displaying

        router.get("user", ID.parameter, use: ProfileController.renderView)

        // profile handling

        router.get("user", ID.parameter, "edit",
            use: ProfileController.renderFormView
        )
        router.post("user", ID.parameter,
            use: ProfileController.dispatch
        )
    }

}
