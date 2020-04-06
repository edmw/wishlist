import Foundation
import NIO

// MARK: DisableNotifications

public struct DisableNotifications: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let favoriteID: FavoriteID
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        internal init(_ user: User) {
            self.user = user.representation
        }
    }

}

// MARK: - Actor

extension DomainUserFavoritesActor {

    // MARK: disableNotifications

    public func disableNotifications(
        _ specification: DisableNotifications.Specification,
        _ boundaries: DisableNotifications.Boundaries
    ) throws -> EventLoopFuture<DisableNotifications.Result> {
        let favoriteRepository = self.favoriteRepository
        let logging = self.logging
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return try favoriteRepository.find(by: specification.favoriteID, for: user)
                    .unwrap(or: UserFavoritesActorError.invalidFavoriteForUser)
                    .flatMap { favorite in
                        // disable notifications
                        favorite.notifications = []
                        return favoriteRepository
                            .save(favorite: favorite)
                            .logMessage(.disableNotifications(for: user), using: logging)
                            .map { _ in
                                .init(user)
                            }
                    }
            }
    }

}

extension LoggingMessageRoot {

    fileprivate static func disableNotifications(for user: User) -> LoggingMessageRoot<Favorite> {
        return .init({ favorite in
            LoggingMessage(label: "Disable notifications", subject: favorite, loggables: [user])
        })
    }

}
