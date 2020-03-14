import Domain

import Vapor
import Fluent

extension ProfileController {

    // MARK: Save

    final class ProfileSaveOutcome: Outcome<UserRepresentation, ProfileEditingContext> {}

    func save(
        from request: Request,
        for userid: UserID
    ) throws
        -> EventLoopFuture<ProfileSaveOutcome>
    {
        let userProfileActor = self.userProfileActor
        return try request.content
            .decode(ProfileEditingData.self)
            .flatMap { data in
                var partialUserData = PartialValues<UserValues>()
                partialUserData[\.nickName] = data.inputNickName

                return try userProfileActor
                    .updateProfile(
                        .specification(userBy: userid, from: partialUserData),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        let user = result.user
                        let context = ProfileEditingContext(with: data)
                        return .success(with: user, context: context)
                    }
                    .catchMap(UserProfileActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, data: data)
                    }
            }
    }

    private func handleErrorOnSave(
        with error: UserProfileActorError,
        data: ProfileEditingData
    ) throws
        -> ProfileSaveOutcome
    {
        if case let UserProfileActorError
            .validationError(user, validationError) = error
        {
            var context = ProfileEditingContext(with: data)
            switch validationError {
            case .validationFailed(let properties, _):
                context.invalidNickName = properties.contains(\UserValues.nickName)
            case .uniquenessViolated:
                // a user with the given nickname already exists
                context.duplicateNickName = true
            }
            return .failure(with: user, context: context, has: error)
        }
        else {
            throw error
        }
    }

}
