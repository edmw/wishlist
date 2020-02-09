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

                return try userProfileActor
                    .updateProfile(
                        .specification(userBy: userid, from: partialUserData),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        return try self.handleSuccessOnSave(with: result, formdata: formdata)
                    }
                    .catchMap(UserProfileActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, formdata: formdata)
                    }
            }
    }

    private func handleSuccessOnSave(
        with result: UpdateProfile.Result,
        formdata: ProfilePageFormData
    ) throws -> ProfileSaveOutcome {
        let user = result.user
        let context = try ProfilePageContext.builder
            .withFormData(formdata)
            .forUser(user)
            .build()
        return .success(with: user, context: context)
    }

    private func handleErrorOnSave(
        with error: UserProfileActorError,
        formdata: ProfilePageFormData
    ) throws
        -> ProfileSaveOutcome
    {
        if case let UserProfileActorError
            .validationError(user, error) = error
        {
            var context = try ProfilePageContext.builder
                .withFormData(formdata)
                .forUser(user)
                .build()
            switch error {
            case .validationFailed(let properties, _):
                context.form.invalidNickName = properties.contains(\UserValues.nickName)
            case .uniquenessViolated:
                // a user with the given nickname already exists
                context.form.duplicateNickName = true
            }
            return .failure(with: error, context: context)
        }
        else {
            throw error
        }
    }

}
