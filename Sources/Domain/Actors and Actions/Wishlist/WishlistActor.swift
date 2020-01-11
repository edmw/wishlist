import Foundation
import NIO

// MARK: WishlistActor

/// Wishlist use cases for guests and the user.
public protocol WishlistActor {

    func presentWishlist(
        _ specification: PresentWishlist.Specification,
        _ boundaries: PresentWishlist.Boundaries
    ) throws -> EventLoopFuture<PresentWishlist.Result>

    func presentReservation(
        _ specification: PresentReservation.Specification,
        _ boundaries: PresentReservation.Boundaries
    ) throws -> EventLoopFuture<PresentReservation.Result>

    func addReservationToItem(
        _ specification: AddReservationToItem.Specification,
        _ boundaries: AddReservationToItem.Boundaries
    ) throws -> EventLoopFuture<AddReservationToItem.Result>

    func removeReservationFromItem(
        _ specification: RemoveReservationFromItem.Specification,
        _ boundaries: RemoveReservationFromItem.Boundaries
    ) throws -> EventLoopFuture<RemoveReservationFromItem.Result>

}

/// Errors thrown by the Wishlist actor.
public enum WishlistActorError: Error {
    case notAuthorized
    case invalidList
    case invalidItem
    case invalidReservation
    case itemReservationExist
    case itemHolderMismatch
}

/// This is the domain’s implementation of the Wishlist use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainWishlistActor: WishlistActor,
    AddReservationToItemActor,
    RemoveReservationFromItemActor
{
    let listRepository: ListRepository
    let itemRepository: ItemRepository
    let reservationRepository: ReservationRepository
    let favoriteRepository: FavoriteRepository
    let userRepository: UserRepository

    let logging: MessageLoggingProvider
    let recording: EventRecordingProvider

    public required init(
        listRepository: ListRepository,
        itemRepository: ItemRepository,
        reservationRepository: ReservationRepository,
        favoriteRepository: FavoriteRepository,
        userRepository: UserRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.listRepository = listRepository
        self.favoriteRepository = favoriteRepository
        self.reservationRepository = reservationRepository
        self.itemRepository = itemRepository
        self.userRepository = userRepository
        self.logging = logging
        self.recording = recording
    }

}
