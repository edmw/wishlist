import Vapor
import Fluent

// MARK: - Controller Parameters

extension ControllerParameterKeys {
    static let message = ControllerParameterKey<WishlistControllerParameterMValue>("m")
}

// messages to display
enum WishlistControllerParameterMValue: String, ControllerParameterValue {
    // Wish already reserved (this is possible because of a race condition)
    case wishAlreadyReserved = "WAR"
}

// MARK: - Controller

/// Controller for displaying and handling a wishlist.
final class WishlistController: ProtectedController,
    ListParameterAcceptor,
    SortingController,
    RouteCollection
{
    typealias Sorting = ItemsSorting

    let listRepository: ListRepository
    let itemRepository: ItemRepository
    let favoriteRepository: FavoriteRepository

    init(
        _ listRepository: ListRepository,
        _ itemRepository: ItemRepository,
        _ favoriteRepository: FavoriteRepository
    ) {
        self.listRepository = listRepository
        self.itemRepository = itemRepository
        self.favoriteRepository = favoriteRepository
    }

    /// Renders the view for a wishlist.
    private func renderView(
        for list: List,
        of owner: User,
        identification: Identification,
        user: User?,
        on request: Request
    ) throws -> EventLoopFuture<View> {
        let sorting = getSorting(on: request) ?? .ascending(by: \Item.title)
        // get all items and their reservations and render page
        let itemContextsBuilder = ItemContextsBuilder(self.itemRepository)
            .forList(list)
            .withSorting(list.itemsSorting ?? sorting)
        return try itemContextsBuilder.build(on: request)
            .map(to: WishlistPageContext.self) { itemContexts in
                var contextBuilder = WishlistPageContextBuilder()
                    .forList(list)
                    .forOwner(owner)
                    .withItems(itemContexts)
                    .forIdentification(identification)
                if let user = user {
                    contextBuilder = contextBuilder.withUser(user)
                }
                return try contextBuilder.build()
            }
            .flatMap(to: WishlistPageContext.self) { context in
                // if user is present check if list is a favorite list
                if let user = user {
                    return try self.favoriteRepository
                        .find(favorite: list, for: user)
                        .map { favorite in
                            // modify context
                            var newContext = context
                            newContext.userFavorsList = favorite != nil
                            return newContext
                        }
                }
                else {
                    // pass on unmodified context
                    return request.future(context)
                }
            }
            .flatMap(to: View.self) { context in
                return try Controller.renderView(
                    "Protected/Wishlist",
                    with: context,
                    on: request
                )
            }
    }

    /// Renders the view for a wishlist.
    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        // find list for the given list id
        return try self.requireList(on: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try self.requireAuthorization(on: request, for: list, user: user)
                    .flatMap { authorization in
                        // get all items and their reservations and render page
                        return try self.renderView(
                            for: authorization.resource,
                            of: authorization.owner,
                            identification: identification,
                            user: authorization.subject,
                            on: request
                        )
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    func boot(router: Router) throws {
        router.get("list", ID.parameter,
            use: self.renderView
        )
    }

}
