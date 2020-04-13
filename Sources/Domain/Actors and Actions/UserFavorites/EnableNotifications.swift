import Foundation
import NIO

// MARK: EnableNotification

public struct EnableNotifications: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
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

    // MARK: enableNotifications

    public func enableNotifications(
        _ specification: EnableNotifications.Specification,
        _ boundaries: EnableNotifications.Boundaries
    ) throws -> EventLoopFuture<EnableNotifications.Result> {
        let favoriteRepository = self.favoriteRepository
        let listRepository = self.listRepository
        let logging = self.logging
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return listRepository.find(by: specification.listID)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .flatMap { list in
                        return try favoriteRepository.find(favorite: list, for: user)
                            .unwrap(or: UserFavoritesActorError.invalidFavoriteForUser)
                            .flatMap { favorite in
                                // enable notifications
                                favorite.notifications = [.itemCreated]
                                return favoriteRepository
                                    .save(favorite: favorite)
                                    .logMessage(.enableNotifications(for: user), using: logging)
                                    .map { _ in
                                        .init(user)
                                    }
                            }
                    }
            }
    }

}

extension LoggingMessageRoot {

    fileprivate static func enableNotifications(for user: User) -> LoggingMessageRoot<Favorite> {
        return .init({ favorite in
            LoggingMessage(label: "Enable notifications", subject: favorite, loggables: [user])
        })
    }

}
