import Foundation
import NIO

struct FavoriteService {

    /// Repository for Favorites to be used by this service.
    let favoriteRepository: FavoriteRepository

    /// Initializes an Favorite service.
    /// - Parameter favoriteRepository: Repository for Favorites to be used by this service.
    init(_ favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func notifyUsers(
        for list: List,
        using notificationSending: NotificationSendingProvider,
        on worker: EventLoop
    ) throws
        -> EventLoopFuture<Void>
    {
        return try favoriteRepository.favoritesAndUser(for: list)
            .flatMap { favoritesAndUsers in
                var futures = [EventLoopFuture<Void>]()
                for (favorite, user) in favoritesAndUsers {
                    guard favorite.notifications.contains(.itemCreated) else {
                        continue
                    }
                    try futures.append(notificationSending.notifyItemCreate(on: list, for: user))
                }
                return futures.flatten(on: worker).transform(to: ())
            }
    }

}

/// Errors thrown by the Favorite Service.
enum FavoriteServiceError: Error {
}
