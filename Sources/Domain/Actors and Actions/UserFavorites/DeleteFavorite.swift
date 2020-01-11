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
                return try listRepository.find(by: specification.listID, for: user)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .flatMap { list in
                        return try favoriteRepository.find(favorite: list, for: user)
                            .unwrap(or: UserFavoritesActorError.invalidFavoriteForUser)
                            .flatMap { favorite in
                                return try favoriteRepository
                                    .deleteFavorite(favorite)
                                    .recordEvent("deleted for \(user)", using: recording)
                                    .logMessage("deleted for \(user)", using: logging)
                                    .map { _ in
                                        .init(user)
                                    }
                            }
                    }
            }
    }

}
