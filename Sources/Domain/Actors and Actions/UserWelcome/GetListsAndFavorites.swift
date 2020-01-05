import Foundation
import NIO

// MARK: GetListsAndFavorites

public final class GetListsAndFavorites: Action {

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
        public static func specification(userBy userid: UserID) -> Self {
            return Self(userID: userid)
        }
    }

    // MARK: Result

    public struct Result {
        public let user: UserRepresentation
        public let lists: [ListRepresentation]
        public let favorites: [FavoriteRepresentation]
        internal init(
            _ user: UserRepresentation,
            lists: [ListRepresentation],
            favorites: [FavoriteRepresentation]
        ) {
            self.user = user
            self.lists = lists
            self.favorites = favorites
        }
    }

}

// MARK: - Actor

extension DomainUserWelcomeActor {

    // MARK: getListsAndFavorites

    public func getListsAndFavorites(
        _ specification: GetListsAndFavorites.Specification,
        _ boundaries: GetListsAndFavorites.Boundaries
    ) throws -> EventLoopFuture<GetListsAndFavorites.Result> {
        let worker = boundaries.worker
        let listRepository = self.listRepository
        let favoriteRepository = self.favoriteRepository
        let itemRepository = self.itemRepository
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserWelcomeActorError.invalidUser)
            .flatMap { user in
                let lists = try ListRepresentationsBuilder(listRepository, itemRepository)
                    .forUser(user)
                    .withSorting(.ascending(by: \List.title))
                    .includeItemsCount(true)
                    .build(on: worker)
                let favorites = try FavoriteRepresentationsBuilder(
                        favoriteRepository,
                        listRepository,
                        itemRepository
                    )
                    .forUser(user)
                    .withSorting(.ascending(by: \List.title))
                    .includeItemsCount(true)
                    .build(on: worker)
                return lists.flatMap { lists in
                    return favorites.map { favorites in
                        return .init(user.representation, lists: lists, favorites: favorites)
                    }
                }
            }
    }

}
