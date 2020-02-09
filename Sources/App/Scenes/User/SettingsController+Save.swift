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

                return try userSettingsActor
                    .updateSettings(
                        .specification(userBy: userid, from: partialSettings),
                        .boundaries(worker: request.eventLoop)
                    )
                    .map { result in
                        return try self.handleSuccessOnSave(with: result, formdata: formdata)
                    }
                    .catchMap(UserSettingsActorError.self) { error in
                        return try self.handleErrorOnSave(with: error, formdata: formdata)
                    }
            }
    }

    private func handleSuccessOnSave(
        with result: UpdateSettings.Result,
        formdata: SettingsPageFormData
    ) throws -> SettingsSaveOutcome {
        let user = result.user
        let context = try SettingsPageContext.builder
            .withFormData(formdata)
            .forUser(user)
            .build()
        return .success(with: user, context: context)
    }

    private func handleErrorOnSave(
        with error: UserSettingsActorError,
        formdata: SettingsPageFormData
    ) throws
        -> SettingsSaveOutcome
    {
        if case let UserSettingsActorError
            .validationError(user, error) = error
        {
            var context = try SettingsPageContext.builder
                .withFormData(formdata)
                .forUser(user)
                .build()
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
        else {
            throw error
        }
    }

}
