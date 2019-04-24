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
            .flatMap(to: View.self, { results in
                let itemContexts
                    = results.map { result -> ItemContext in
                        let (item, reservation) = result
                        return ItemContext(for: item, with: reservation)
                    }
                let context
                    = WishlistPageContext(
                        for: list,
                        of: owner,
                        with: itemContexts,
                        user: user,
                        identification: identification
                    )
                return try renderView(
                    "Protected/Wishlist",
                    with: context,
                    on: request
                )
            })
    }

    /// Renders the view for a wishlist.
    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        // find list for the given list id
        let listID = try request.parameters.next(ID.self)
        return try request.make(ListRepository.self)
            .find(by: listID.uuid)
            .unwrap(or: Abort(.notFound))
            .flatMap { list in

                // get owner of the found list
                return list.user.get(on: request)
                    .flatMap { owner in
                        // check if the found list may be accessed by the given user
                        // user may be nil indicating this is a anonymous request
                        try requireAuthorization(on: request, for: list, owner: owner, user: user)

                        // get all items and their reservations and render page
                        return try renderView(
                            for: list,
                            of: owner,
                            identification: identification,
                            user: user,
                            on: request
                        )
                    }
                    .catchFlatMap(AuthorizationError.self) { error in
                        request.logger?.application.debug("\(error)")
                        switch error {
                        case .authenticationRequired:
                            throw Abort(.unauthorized)
                        default:
                            throw Abort(.notFound)
                        }
                    }
            }
    }

    func boot(router: Router) throws {
        router.get("list", ID.parameter,
            use: WishlistController.renderView
        )
    }

}
