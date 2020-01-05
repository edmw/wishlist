import Domain

import Vapor
import Fluent

extension SettingsController {

    // MARK: Save

    final class SettingsSaveOutcome: Outcome<UserRepresentation, SettingsPageContext> {}

    func save(
        from request: Request,
        for userid: UserID
    ) throws
        -> EventLoopFuture<SettingsSaveOutcome>
    {
        let userSettingsActor = self.userSettingsActor
        return try request.content
            .decode(SettingsPageFormData.self)
            .flatMap { formdata in
                var partialSettings = PartialValues<UserSettings>()
                partialSettings[\.notifications.emailEnabled] = formdata.inputEmail ?? false
                partialSettings[\.notifications.pushoverEnabled] = formdata.inputPushover ?? false
                partialSettings[\.notifications.pushoverKey]
                    = formdata.inputPushoverKey.map { PushoverKey(string: $0) }

                var contextBuilder = SettingsPageContextBuilder().withFormData(formdata)

                return try userSettingsActor
                    .updateSettings(
                        .specification(userBy: userid, from: partialSettings),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        contextBuilder = contextBuilder.forUserRepresentation(result.user)
                        return try .success(with: result.user, context: contextBuilder.build())
                    }
                    .catchMap(UserSettingsActorError.self) { error in
                        if case let UserSettingsActorError
                            .validationError(user, error) = error
                        {
                            contextBuilder = contextBuilder.forUserRepresentation(user)
                            return try self.handleErrorOnSave(error, with: contextBuilder.build())
                        }
                        throw error
                    }
            }
    }

    private func handleErrorOnSave(
        _ error: ValuesError<UserSettings>,
        with contextIn: SettingsPageContext
    ) throws
        -> SettingsSaveOutcome
    {
        var context = contextIn
        switch error {
        case .validationFailed(let properties, _):
            context.form.missingPushoverKey
                = properties.contains(\UserSettings.self)
            context.form.invalidPushoverKey
                = properties.contains(\UserSettings.notifications.pushoverKey)
        default:
            throw error
        }
        return .failure(with: error, context: context)
    }

}
