import Foundation
import NIO

// MARK: GetFavorites

public final class GetFavorites: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public static func boundaries(worker: EventLoop) -> Self {
            return Self(worker: worker)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public let sorting: ListsSorting
        public let includeItemsCount: Bool
        public static func specification(
            userBy userid: UserID,
            with sorting: ListsSorting = .ascending(by: \List.title),
            includeItemsCount: Bool = true
        ) -> Self {
            return Self(userID: userid, sorting: sorting, includeItemsCount: includeItemsCount)
        }
    }

    // MARK: Result

    public struct Result {
        public let user: UserRepresentation
        public let favorites: [FavoriteRepresentation]
        internal init(_ user: User, favorites: [FavoriteRepresentation]) {
            self.user = user.representation
            self.favorites = favorites
        }
    }

}

// MARK: - Actor

extension DomainUserFavoritesActor {

    // MARK: getFavorites

    public func getFavorites(
        _ specification: GetFavorites.Specification,
        _ boundaries: GetFavorites.Boundaries
    ) throws -> EventLoopFuture<GetFavorites.Result> {
        let worker = boundaries.worker
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return try self.favoriteRepresentationsBuilder
                    .reset()
                    .forUser(user)
                    .withSorting(specification.sorting)
                    .includeItemsCount(specification.includeItemsCount)
                    .build(on: worker)
                    .map { favorites in
                        .init(user, favorites: favorites)
                    }
            }
    }

}
