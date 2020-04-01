import Domain

import Vapor

extension SettingsController {

    // MARK: Save

    final class SettingsSaveOutcome: Outcome<UserRepresentation, SettingsEditingContext> {}

    func save(
        from request: Request,
        for userid: UserID
    ) throws
        -> EventLoopFuture<SettingsSaveOutcome>
    {
        let userSettingsActor = self.userSettingsActor
        return try request.content
            .decode(SettingsEditingData.self)
            .flatMap { data in
                var partialSettings = PartialValues<UserSettings>()
                partialSettings[\.notifications.emailEnabled] = data.inputEmail ?? false
                partialSettings[\.notifications.pushoverEnabled] = data.inputPushover ?? false
                partialSettings[\.notifications.pushoverKey]
                    = data.inputPushoverKey.map { PushoverKey(string: $0) }

                return try userSettingsActor
                    .updateSettings(
                        .specification(userBy: userid, from: partialSettings),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        let user = result.user
                        let context = SettingsEditingContext(with: data)
                        return .success(with: user, context: context)
                    }
                    .catchMap(UserSettingsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, data: data)
                    }
            }
    }

    private func handleErrorOnSave(
        with error: UserSettingsActorError,
        data: SettingsEditingData
    ) throws
        -> SettingsSaveOutcome
    {
        if case let UserSettingsActorError
            .validationError(user, error) = error
        {
            var context = SettingsEditingContext(with: data)
            switch error {
            case .validationFailed(let properties, _):
                context.missingPushoverKey
                    = properties.contains(\UserSettings.self)
                context.invalidPushoverKey
                    = properties.contains(\UserSettings.notifications.pushoverKey)
            default:
                throw error
            }
            return .failure(with: user, context: context, has: error)
        }
        else {
            throw error
        }
    }

}
