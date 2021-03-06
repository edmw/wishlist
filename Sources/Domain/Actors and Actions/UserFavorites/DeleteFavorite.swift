import Foundation
import NIO

// MARK: DeleteFavorite

public struct DeleteFavorite: Action {

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

    // MARK: deleteFavorite

    public func deleteFavorite(
        _ specification: DeleteFavorite.Specification,
        _ boundaries: DeleteFavorite.Boundaries
    ) throws -> EventLoopFuture<DeleteFavorite.Result> {
        let listRepository = self.listRepository
        let favoriteRepository = self.favoriteRepository
        let logging = self.logging
        let recording = self.recording
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return listRepository.find(by: specification.listID)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .flatMap { list in
                        return try favoriteRepository.find(favorite: list, for: user)
                            .unwrap(or: UserFavoritesActorError.invalidFavoriteForUser)
                            .flatMap { favorite in
                                // delete favorite
                                let id = favorite.id
                                return try favoriteRepository
                                    .delete(favorite: favorite)
                                    .logMessage(.deleteFavorite(with: id), using: logging)
                                    .recordEvent(.deleteFavorite(with: id), using: recording)
                                    .map { _ in
                                        .init(user)
                                    }
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func deleteFavorite(with id: FavoriteID?) -> LoggingMessageRoot<Favorite> {
        return .init({ favorite in
            LoggingMessage(label: "Delete Favorite", subject: favorite, loggables: [id])
        })
    }

}

// MARK: Recording

extension RecordingEventRoot {

    fileprivate static func deleteFavorite(with id: FavoriteID?) -> RecordingEventRoot<Favorite> {
        return .init({ favorite in
            RecordingEvent(.DELETEENTITY, subject: favorite, attributes: ["id": id as Any])
        })
    }

}
