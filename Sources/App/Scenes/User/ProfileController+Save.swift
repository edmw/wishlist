import Vapor
import Fluent

extension ProfileController {

    // MARK: Save

    final class ProfileSaveOutcome: Outcome<User, ProfilePageContext> {}

    /// Saves a profile for the specified user from the request’s data.
    /// Validates the data contained in the request and updates the user.
    func save(
        from request: Request,
        for user: User
    ) throws
        -> EventLoopFuture<ProfileSaveOutcome>
    {
        return try request.content
            .decode(ProfilePageFormData.self)
            .flatMap { formdata in
                let context = try ProfilePageContextBuilder()
                    .forUser(user)
                    .withFormData(formdata)
                    .build()

                return request.future()
                    .flatMap {
                        return try self.save(
                            from: formdata, for: user, on: request
                        )
                        .map { user in .success(with: user, context: context) }
                    }
                    .catchMap(EntityError<User>.self) {
                        try self.handleErrorOnSave($0, with: context)
                    }
            }
    }

    private func handleErrorOnSave(
        _ error: EntityError<User>,
        with contextIn: ProfilePageContext
    ) throws
        -> ProfileSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidNickName = properties.contains(\User.nickName)
        case .uniquenessViolated:
            // an user with the given nickname already exists
            context.form.duplicateNickName = true
        default:
            throw error
        }
        return .failure(with: error, context: context)
    }

    /// Saves an user from the given form data.
    /// Validates the data, checks the constraints required for an updated user and updates an
    /// existing user.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private func save(
        from formdata: ProfilePageFormData,
        for user: User,
        on request: Request
    ) throws
        -> EventLoopFuture<User>
    {
        var userData = UserData(user)
        userData.update(from: formdata)
        return try userData
            .validate(using: userRepository, on: request)
            .flatMap { data in
                // save user

                try user.update(from: data)

                return self.userRepository.save(user: user)
            }
    }

}
