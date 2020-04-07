/// Errors thrown by the User Settings actor.
public enum UserSettingsActorError: Error {
    case invalidUser
    case validationError(UserRepresentation, ValuesError<UserSettings>)
}
