/// Errors thrown by the User Profile actor.
public enum UserProfileActorError: Error {
    case invalidUser
    case validationError(UserRepresentation, ValuesError<UserValues>)
}
