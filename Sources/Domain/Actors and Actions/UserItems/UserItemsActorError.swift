/// Errors thrown by the User Items actor.
public enum UserItemsActorError: Error {
    case invalidUser
    case invalidList
    case invalidItem
    case validationError(
        UserRepresentation, ListRepresentation, ItemRepresentation?, ValuesError<ItemValues>
    )
    case itemNotMovable
    case itemNotReceivable
    case itemNotDeletable
    case itemNotArchivable
}
