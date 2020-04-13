import Foundation
import NIO

struct FavoriteService {

    /// Repository for Favorites to be used by this service.
    let favoriteRepository: FavoriteRepository
    /// Repository for Lists to be used by this service.
    let listRepository: ListRepository

    let logging: MessageLogging

    /// Initializes an Favorite service.
    /// - Parameter favoriteRepository: Repository for Favorites to be used by this service.
    init(
        _ favoriteRepository: FavoriteRepository,
        _ listRepository: ListRepository,
        _ logging: MessageLogging
    ) {
        self.favoriteRepository = favoriteRepository
        self.listRepository = listRepository
        self.logging = logging
    }

    func notifyUsers(
        for list: List,
        using notificationSending: NotificationSendingProvider,
        on worker: EventLoop
    ) throws
        -> EventLoopFuture<Void>
    {
        let listRepository = self.listRepository
        let logging = self.logging
        return try favoriteRepository.favoritesAndUser(for: list)
            .flatMap { favoritesAndUsers in
                var futures = [EventLoopFuture<Void>]()
                for (favorite, user) in favoritesAndUsers {
                    guard favorite.notifications.contains(.itemCreated) else {
                        continue
                    }
                    try futures.append(
                        list.authorize(in: listRepository, for: user)
                            .flatMap { _ in
                                try notificationSending.notifyItemCreate(on: list, for: user)
                            }
                            .catchMap { error in
                                // ignore authorization errors
                                // usually, this means a user was allowed to favor the list once,
                                // but the visibility has changed since then
                                if error is AuthorizationError {
                                    logging.info("Favorite notification error: \(error)")
                                    return
                                }
                                // rethrow any other errors
                                throw error
                            }
                    )
                }
                return futures.flatten(on: worker).transform(to: ())
            }
    }

}

/// Errors thrown by the Favorite Service.
enum FavoriteServiceError: Error {
}
