import Domain

import Vapor
import Fluent

extension ProfileController {

    // MARK: Save

    final class ProfileSaveOutcome: Outcome<UserRepresentation, ProfilePageContext> {}

    func save(
        from request: Request,
        for userid: UserID
    ) throws
        -> EventLoopFuture<ProfileSaveOutcome>
    {
        let userProfileActor = self.userProfileActor
        return try request.content
            .decode(ProfilePageFormData.self)
            .flatMap { formdata in
                var partialUserData = PartialValues<UserValues>()
                partialUserData[\.nickName] = formdata.inputNickName

                var contextBuilder = ProfilePageContextBuilder().withFormData(formdata)

                return try userProfileActor
                    .updateProfile(
                        .specification(userBy: userid, from: partialUserData),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        contextBuilder = contextBuilder.forUser(result.user)
                        return try .success(with: result.user, context: contextBuilder.build())
                    }
                    .catchMap(UserProfileActorError.self) { error in
                        if case let UserProfileActorError
                            .validationError(user, error) = error
                        {
                            contextBuilder = contextBuilder.forUser(user)
                            return try self.handleErrorOnSave(error, with: contextBuilder.build())
                        }
                        throw error
                    }
            }
    }

    private func handleErrorOnSave(
        _ error: ValuesError<UserValues>,
        with contextIn: ProfilePageContext
    ) throws
        -> ProfileSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.invalidNickName = properties.contains(\UserValues.nickName)
        case .uniquenessViolated:
            // a user with the given nickname already exists
            context.form.duplicateNickName = true
        }
        return .failure(with: error, context: context)
    }

}
