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
final class WishlistController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ItemsSorting

    /// Renders the view for a wishlist.
    private static func renderView(
        for list: List,
        of owner: User,
        identification: Identification,
        user: User?,
        on request: Request
    ) throws -> Future<View> {
        let sorting = getSorting(on: request) ?? .ascending(by: \Item.name)
        // get all items and their reservations and render page
        return try request.make(ItemRepository.self)
            .allAndReservations(for: list, sort: list.itemsSorting ?? sorting)
            .map(to: WishlistPageContext.self) { results in
                let itemContexts
                    = results.map { result -> ItemContext in
                        let (item, reservation) = result
                        return ItemContext(for: item, with: reservation)
                    }
                return WishlistPageContext(
                    for: list,
                    of: owner,
                    with: itemContexts,
                    user: user,
                    identification: identification
                )
            }
            .flatMap(to: WishlistPageContext.self) { context in
                // if user is present check if list is a favorite list
                if let user = user {
                    return try request.make(FavoritesRepository.self)
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
                return try renderView(
                    "Protected/Wishlist",
                    with: context,
                    on: request
                )
            }
    }

    /// Renders the view for a wishlist.
    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        // find list for the given list id
        return try requireList(on: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try requireAuthorization(on: request, for: list, user: user)
                    .flatMap { authorization in
                        // get all items and their reservations and render page
                        return try renderView(
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
            use: WishlistController.renderView
        )
    }

}
