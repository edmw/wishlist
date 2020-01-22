import Foundation
import NIO

// MARK: UserSettings

extension UserSettings: Values, ValueValidatable {

    // MARK: Validatable

    static func valueValidations() throws -> ValueValidations<UserSettings> {
        var validations = ValueValidations(UserSettings.self)

        validations.add(
            "pushoverkey is not set while pushover is enabled",
            validate: { settings in
                guard !settings.notifications.pushoverEnabled
                    || !settings.notifications.pushoverKey.isEmpty else {
                    throw ValueValidationError("'notifications.pushoverKey' is missing")
                }
            }
        )
        validations.add(
            \UserSettings.notifications.pushoverKey,
            ".notifications.pushoverKey",
            .empty || .pushoverKey
        )

        return validations
    }

    /// Validates the given user data on conformance to the constraints of the model.
    /// - Values must validate (see Validatable)
    /// - Nickname must be unique
    func validate(using repository: UserRepository) throws
        -> EventLoopFuture<UserSettings>
    {
        do {
            try validateValues()
        }
        catch let error as ValueValidationErrors<UserSettings> {
            return repository.future(
                error: ValuesError<UserSettings>
                    .validationFailed(on: error.failedKeyPaths, reason: error.reason)
            )
        }
        return repository.future(self)
    }

}
