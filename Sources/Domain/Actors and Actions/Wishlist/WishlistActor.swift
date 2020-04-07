import Foundation
import NIO

// MARK: WishlistActor

/// Wishlist use cases for guests and the user.
public protocol WishlistActor: Actor {

    /// Returns all information necessary to display a wishlist.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user (which can be anonymous or authenticated) is entitled to
    /// see the specified wishlist (throws an authorization error otherwise).
    ///
    /// Specification:
    /// - `listID`: ID for the requested list
    /// - `sorting`: Optional sort order for the items of the list
    /// - `identification`: Identification for the user (either anonymous or authenticated)
    /// - `userID`: Optional ID of the user if authenticated
    ///
    /// Boundaries:
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result {
    ///   let list: ListRepresentation
    ///   let items: [ItemRepresentation]
    ///   let isFavorite: Bool
    ///   let owner: UserRepresentation
    ///   let user: UserRepresentation?
    ///   let identification: Identification
    /// }
    /// ```
    func presentWishlist(
        _ specification: PresentWishlist.Specification,
        _ boundaries: PresentWishlist.Boundaries
    ) throws -> EventLoopFuture<PresentWishlist.Result>

    /// Returns all information necessary to display an item and a maybe existing reservation.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user (which can be anonymous or authenticated) is entitled to
    /// access the specified item and list (throws an authorization error otherwise).
    ///
    /// Specification:
    /// - `itemID`: ID for the requested item
    /// - `listID`: ID for the requested list
    /// - `identification`: Identification for the user (either anonymous or authenticated)
    /// - `userID`: Optional ID of the user if authenticated
    ///
    /// Boundaries:
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result {
    ///   let identification: Identification
    ///   let item: ItemRepresentation
    ///   let list: ListRepresentation
    ///   let reservation: ReservationRepresentation?
    /// }
    /// ```
    func presentReservation(
        _ specification: PresentReservation.Specification,
        _ boundaries: PresentReservation.Boundaries
    ) throws -> EventLoopFuture<PresentReservation.Result>

    /// Adds a reservation to the specified item.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user (which can be anonymous or authenticated) is entitled to
    /// access the specified item and list (throws an authorization error otherwise).
    ///
    /// Specification:
    /// - `itemID`: ID for the requested item
    /// - `listID`: ID for the requested list
    /// - `identification`: Identification for the user (either anonymous or authenticated)
    /// - `userID`: Optional ID of the user if authenticated
    ///
    /// Boundaries:
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result {
    ///   let reservation: ReservationRepresentation
    ///   let item: ItemRepresentation
    ///   let list: ListRepresentation
    /// }
    /// ```
    func addReservationToItem(
        _ specification: AddReservationToItem.Specification,
        _ boundaries: AddReservationToItem.Boundaries
    ) throws -> EventLoopFuture<AddReservationToItem.Result>

    /// Removes a reservation from the specified item.
    /// - Parameter specification: Specification for this action.
    /// - Parameter boundaries: Boundaries for this action.
    /// - Throws: AuthorizationError
    ///
    /// This actions checks if the user (which can be anonymous or authenticated) is entitled to
    /// access the specified item and list (throws an authorization error otherwise).
    ///
    /// Specification:
    /// - `reservationID`: ID of the reservation to remove
    /// - `listID`: ID for the requested list
    /// - `identification`: Identification for the user (either anonymous or authenticated)
    /// - `userID`: Optional ID of the user if authenticated
    ///
    /// Boundaries:
    /// - `worker`: EventLoop
    ///
    /// The result returned by this action:
    /// ```
    /// struct Result {
    ///   let item: ItemRepresentation
    ///   let list: ListRepresentation
    /// }
    /// ```
    func removeReservationFromItem(
        _ specification: RemoveReservationFromItem.Specification,
        _ boundaries: RemoveReservationFromItem.Boundaries
    ) throws -> EventLoopFuture<RemoveReservationFromItem.Result>

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

    let logging: MessageLogging
    let recording: EventRecording

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
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
    }

}
