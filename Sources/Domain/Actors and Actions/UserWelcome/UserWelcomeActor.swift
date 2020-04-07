import Foundation
import NIO

// MARK: UserWelcomeActor

/// Welcome use cases for the user.
public protocol UserWelcomeActor: Actor {

    func getListsAndFavorites(
        _ specification: GetListsAndFavorites.Specification,
        _ boundaries: GetListsAndFavorites.Boundaries
    ) throws -> EventLoopFuture<GetListsAndFavorites.Result>

}

/// This is the domain’s implementation of the Welcome use cases. Actions will extend this by
/// their corresponding use case methods.
public final class DomainUserWelcomeActor: UserWelcomeActor {

    let listRepository: ListRepository
    let favoriteRepository: FavoriteRepository
    let itemRepository: ItemRepository
    let userRepository: UserRepository

    public required init(
        listRepository: ListRepository,
        favoriteRepository: FavoriteRepository,
        itemRepository: ItemRepository,
        userRepository: UserRepository
    ) {
        self.listRepository = listRepository
        self.favoriteRepository = favoriteRepository
        self.itemRepository = itemRepository
        self.userRepository = userRepository
    }

}
