/// Errors thrown by the Wishlist actor.
public enum WishlistActorError: Error {
    case invalidIdentification
    case invalidList
    case invalidItem
    case invalidReservation
    case itemReservationExist
    case itemHolderMismatch
}
