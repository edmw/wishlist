import Vapor
import Fluent

final class ReservationControllerForOwner: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    /// Renders a view to confirm the deletion of a reservation.
    private static func renderDeleteView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        return try ReservationController.requireReservation(on: request, for: item)
                            .flatMap { reservation in
                                let context = try ReservationPageContextBuilder()
                                    .forUser(user)
                                    .forItem(item)
                                    .forList(list)
                                    .withReservation(reservation)
                                    .build()
                                return try renderView(
                                    "User/ReservationDeletion",
                                    with: context,
                                    on: request
                                )
                            }
                    }
            }
    }

    // MARK: - CRUD

    private static func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        return try ReservationController.requireReservation(on: request, for: item)
                            .deleteModel(on: request)
                            .emitEvent("deleted by \(user)", on: request)
                            .logMessage("deleted by \(user)", on: request)
                            .transform(to: success(for: user, and: list, on: request))
                    }
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for user: User, and list: List, on request: Request)
        -> Response
    {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return redirect(to: locator.locationString, on: request)
        }
        else {
            return redirect(for: user, and: list, to: "items", on: request)
        }
    }

    // MARK: - Routing

    private static func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .DELETE:
                    return try delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // reservation handling (for owners)

        router.get(
            "user", ID.parameter,
            "list", ID.parameter,
            "item", ID.parameter,
            "reservation", ID.parameter,
            "delete",
            use: ReservationControllerForOwner.renderDeleteView
        )
        router.post(
            "user", ID.parameter,
            "list", ID.parameter,
            "item", ID.parameter,
            "reservation", ID.parameter,
            use: ReservationControllerForOwner.dispatch
        )

    }

}
