import Vapor
import Fluent

extension SettingsController {

    // MARK: Save

    final class SettingsSaveOutcome: Outcome<UserSettings, SettingsPageContext> {}

    /// Saves settings for the specified user from the request’s data.
    /// Validates the data contained in the request and updates the user.
    func save(
        from request: Request,
        for user: User
    ) throws
        -> EventLoopFuture<SettingsSaveOutcome>
    {
        return try request.content
            .decode(SettingsPageFormData.self)
            .flatMap { formdata in
                var context = try SettingsPageContextBuilder()
                    .forUser(user)
                    .withFormData(formdata)
                    .build()

                return request.future()
                    .flatMap {
                        return try self.save(from: formdata, for: user, on: request)
                            .map { settings in .success(with: settings, context: context) }
                    }
                    .catchMap(ValidationError.self) { error in
                        // WORKAROUND: See https://github.com/vapor/validation/issues/26
                        // This is a hack which parses the textual reason for an validation error.
                        let reason = error.reason
                        if reason.contains("'pushoverkey' missing") {
                            context.form.missingPushoverKey = true
                        }
                        else {
                            context.form.invalidPushoverKey =
                                reason.contains("'notifications.pushoverKey'")
                        }
                        return .failure(with: error, context: context)
                    }
            }
    }

    /// Saves settings from the given form data.
    /// Validates the data, checks the constraints required for an updated user and updates an
    /// existing user.
    ///
    /// Throws `EntityError`s for invalid data or violated constraints.
    private func save(
        from formdata: SettingsPageFormData,
        for user: User,
        on request: Request
    ) throws
        -> EventLoopFuture<UserSettings>
    {
        var settings = user.settings
        settings.update(from: formdata)
        try settings.validate()
        user.settings = settings
        return userRepository
            .save(user: user)
            .transform(to: settings)
    }

}
