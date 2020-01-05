import Domain

import Vapor
import Fluent

// MARK: - Controller Parameters

extension ControllerParameterKeys {
    static let message = ControllerParameterKey<WishlistControllerParameterMValue>("m")
}

// messages to display
enum WishlistControllerParameterMValue: String, ControllerParameterValue {
    // Wish already reserved (this is possible because of a potential race condition)
    case wishAlreadyReserved = "WAR"
}

// MARK: - Controller

/// Controller for displaying and handling a wishlist.
final class WishlistController: AuthenticatableController,
    SortingController,
    ListParameterAcceptor,
    ItemParameterAcceptor,
    ReservationParameterAcceptor,
    RouteCollection
{
    typealias Sorting = ItemsSorting

    let wishlistActor: WishlistActor

    init(
        _ wishlistActor: WishlistActor
    ) {
        self.wishlistActor = wishlistActor
    }

    // MARK: - VIEWS

    /// Renders the view for a wishlist.
    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let identification = try requireIdentification(on: request)
        let userid = try authenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let sorting = getSorting(on: request) ?? .ascending(by: \Item.title)
        return try wishlistActor
            .presentWishlist(
                .specification(listid, with: sorting, for: identification, userBy: userid),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try WishlistPageContextBuilder()
                    .forListRepresentation(result.list)
                    .forOwnerRepresentation(result.owner)
                    .withUserRepresentation(result.user)
                    .userFavorsList(result.isFavorite)
                    .withItemRepresentations(result.items)
                    .forIdentification(result.identification)
                    .build()
                return try Controller.renderView("Protected/Wishlist", with: context, on: request)
            }
            .handleAuthorizationError(on: request)
    }

    // MARK: VIEWS (Reservations)

    typealias RenderReservationViewCallback
        = (Identification, ItemRepresentation, ListRepresentation, ReservationRepresentation?)
            throws -> EventLoopFuture<View>

    private func renderReservationView(
        on request: Request,
        _ render: @escaping RenderReservationViewCallback
    ) throws -> EventLoopFuture<View> {
        let identification = try self.requireIdentification(on: request)
        let userid = try authenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let wishlistActor = self.wishlistActor
        return try findItemID(from: request)
            .flatMap { itemid in
                return try wishlistActor
                    .presentReservation(
                        .specification(itemid, on: listid, for: identification, userBy: userid),
                        .boundaries(worker: request.eventLoop)
                    )
                    .flatMap { result in
                        return try render(
                            result.identification,
                            result.item,
                            result.list,
                            result.reservation
                        )
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    /// Renders a view to confirm the creation of a reservation.
    private func renderCreateReservationView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try self.renderReservationView(on: request)
            { identification, item, list, _ throws in
                let context = try ReservationPageContextBuilder()
                    .forIdentification(identification)
                    .forItemRepresentation(item)
                    .forListRepresentation(list)
                    .build()
                return try Controller.renderView(
                    "Protected/ReservationCreation",
                    with: context,
                    on: request
                )
        }
    }

    /// Renders a view to confirm the deletion of a reservation.
    private func renderDeleteReservationView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try self.renderReservationView(on: request)
            { identification, item, list, reservation throws in
                let context = try ReservationPageContextBuilder()
                    .forIdentification(identification)
                    .forItemRepresentation(item)
                    .forListRepresentation(list)
                    .withReservationRepresentation(reservation)
                    .build()
                return try Controller.renderView(
                    "Protected/ReservationDeletion",
                    with: context,
                    on: request
                )
        }
    }

    // MARK: - CRUD (Reservations)

    private func createReservation(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try authenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let identification = try self.requireIdentification(on: request)
        let wishlistActor = self.wishlistActor
        return try findItemID(from: request)
            .flatMap { itemid in
                return try wishlistActor
                    .addReservationToItem(
                        .specification(itemid, on: listid, for: identification, userBy: userid),
                        .boundaries(
                            worker: request.eventLoop,
                            notificationSending: VaporNotificationSendingProvider(on: request)
                        )
                    )
                    .map { result in
                        return self.success(for: result.list, on: request)
                    }
                    .catchFlatMap { error in
                        if let wishlistError = error as? WishlistActorError,
                            case WishlistActorError.itemReservationExist = wishlistError
                        {
                             return Controller.redirect(
                                for: listid,
                                parameters: [.value(.wishAlreadyReserved, for: .message)],
                                on: request
                            )
                        }
                        throw error
                    }
            }
    }

    private func deleteReservation(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try authenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let identification = try self.requireIdentification(on: request)
        let reservationid = try self.requireReservationID(on: request)
        return try wishlistActor
            .removeReservationFromItem(
                .specification(reservationid, in: listid, for: identification, userBy: userid),
                .boundaries(
                    worker: request.eventLoop,
                    notificationSending: VaporNotificationSendingProvider(on: request)
                )
            )
            .map { result in
                return self.success(for: result.list, on: request)
            }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for list: ListRepresentation, on request: Request)
        -> Response
    {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return Controller.redirect(to: locator.locationString, on: request)
        }
        else {
            return Controller.redirect(for: list.id, on: request)
        }
    }

    // MARK: - Routing

    private func dispatchForReservation(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .DELETE:
                    return try self.deleteReservation(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // wishlist presentation

        router.get("list", ID.parameter,
            use: self.renderView
        )

        // reservation creation

        router.get("list", ID.parameter, "reservations", "create",
            use: self.renderCreateReservationView
        )
        router.post("list", ID.parameter, "reservations",
            use: self.createReservation
        )

        // reservation handling

        router.get("list", ID.parameter, "reservation", ID.parameter, "delete",
            use: self.renderDeleteReservationView
        )
        router.post("list", ID.parameter, "reservation", ID.parameter,
            use: self.dispatchForReservation
        )

    }

}
