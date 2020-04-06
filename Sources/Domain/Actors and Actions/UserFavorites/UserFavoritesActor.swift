import Foundation
import NIO

// MARK: UserFavoritesActor

/// Favorites use cases for the user.
public protocol UserFavoritesActor: Actor {

    func getFavorites(
        _ specification: GetFavorites.Specification,
        _ boundaries: GetFavorites.Boundaries
    ) throws -> EventLoopFuture<GetFavorites.Result>

    func requestFavoriteCreation(
        _ specification: RequestFavoriteCreation.Specification,
        _ boundaries: RequestFavoriteCreation.Boundaries
    ) throws -> EventLoopFuture<RequestFavoriteCreation.Result>

    func createFavorite(
        _ specification: CreateFavorite.Specification,
        _ boundaries: CreateFavorite.Boundaries
    ) throws -> EventLoopFuture<CreateFavorite.Result>

    func requestFavoriteDeletion(
        _ specification: RequestFavoriteDeletion.Specification,
        _ boundaries: RequestFavoriteDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestFavoriteDeletion.Result>

    func deleteFavorite(
        _ specification: DeleteFavorite.Specification,
        _ boundaries: DeleteFavorite.Boundaries
    ) throws -> EventLoopFuture<DeleteFavorite.Result>

    func enableNotifications(
        _ specification: EnableNotifications.Specification,
        _ boundaries: EnableNotifications.Boundaries
    ) throws -> EventLoopFuture<EnableNotifications.Result>

    func disableNotifications(
        _ specification: DisableNotifications.Specification,
        _ boundaries: DisableNotifications.Boundaries
    ) throws -> EventLoopFuture<DisableNotifications.Result>

}

/// Errors thrown by the User Favorites actor.
public enum UserFavoritesActorError: Error {
    /// An invalid user id was specified. There is no user with the given id.
    case invalidUser
    /// An invalid list id was specified. There is no list with the given id.
    case invalidList
    /// An invalid list id was specified. There is no list with the given id for the specified
    /// user.
    case invalidListForUser
    /// An invalid favorite id was specified. There is no favorite with the given id for the
    /// specified user.
    case invalidFavoriteForUser
    /// Favorite exists already
    case favoriteExisting
    /// Favorite does not exist
    case favoriteNotExisting
}

/// This is the domain’s implementation of the Favorites use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserFavoritesActor: UserFavoritesActor {

    let favoriteRepository: FavoriteRepository
    let listRepository: ListRepository
    let itemRepository: ItemRepository
    let userRepository: UserRepository

    let logging: MessageLogging
    let recording: EventRecording

    let favoriteRepresentationsBuilder: FavoriteRepresentationsBuilder

    public required init(
        favoriteRepository: FavoriteRepository,
        listRepository: ListRepository,
        itemRepository: ItemRepository,
        userRepository: UserRepository,
        logging: MessageLoggingProvider,
        recording: EventRecordingProvider
    ) {
        self.favoriteRepository = favoriteRepository
        self.listRepository = listRepository
        self.itemRepository = itemRepository
        self.userRepository = userRepository
        self.logging = MessageLogging(provider: logging)
        self.recording = EventRecording(provider: recording)
        self.favoriteRepresentationsBuilder
            = FavoriteRepresentationsBuilder(favoriteRepository, listRepository, itemRepository)
    }

}
