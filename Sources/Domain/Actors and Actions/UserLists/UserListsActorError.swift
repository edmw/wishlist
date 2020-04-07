/// Errors thrown by the User Lists actor.
public enum UserListsActorError: Error {
    case invalidUser
    case invalidList
    case validationError(UserRepresentation, ListRepresentation?, ValuesError<ListValues>)
    case importErrorForUser(UserRepresentation)
    case exportErrorForUser(UserRepresentation)
    case listHasReservedItems
}
