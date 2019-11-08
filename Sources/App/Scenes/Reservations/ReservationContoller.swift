import Vapor
import Fluent

final class ReservationController: ProtectedController, RouteCollection {

    private static func allowView(
        on request: Request,
        _ render: @escaping (Identification, Item, List) throws -> EventLoopFuture<View>
    ) throws -> EventLoopFuture<View> {
        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        return try requireList(on: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        return try findItem(in: list, from: request)
                            .flatMap { item in
                                // render the view after authorization
                                return try render(identification, item, list)
                            }
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // MARK: - VIEWS

    /// Renders a view to confirm the creation of a reservation.
    private static func renderCreateView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try allowView(on: request) { (identification, item, list) throws in
            let context = try ReservationPageContextBuilder()
                .forIdentification(identification)
                .forItem(item)
                .forList(list)
                .build()
            return try renderView("Protected/ReservationCreation", with: context, on: request)
        }
    }

    /// Renders a view to confirm the deletion of a reservation.
    private static func renderDeleteView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try allowView(on: request) { (identification, item, list) throws in
            return try requireReservation(on: request, for: item)
                .flatMap { reservation in
                    let context = try ReservationPageContextBuilder()
                        .forIdentification(identification)
                        .forItem(item)
                        .forList(list)
                        .withReservation(reservation)
                        .build()
                    return try renderView(
                        "Protected/ReservationDeletion",
                        with: context,
                        on: request
                    )
                }
        }
    }

    // MARK: - CRUD

    private static func create(on request: Request) throws -> EventLoopFuture<Response> {
        return try authorizeList(on: request) { (identification, list) throws in
            return try save(from: request, in: list, for: identification).flatMap { result in
                switch result {
                case let .success(reservation, item):
                    return try request.future(reservation)
                        .dispatchNotification(on: request) { request, _ in
                            list.user.get(on: request).map { owner in
                                return ReservationCreateNotification(for: owner, on: item, in: list)
                            }
                        }
                        .emitEvent("created on \(item) for \(identification)", on: request)
                        .logMessage("created on \(item) for \(identification)", on: request)
                        .transform(to: success(for: list, on: request))
                case .failureItemReserved:
                    return redirect(
                        for: list,
                        parameters: [.value(.wishAlreadyReserved, for: .message)],
                        on: request
                    )
                }
            }
        }
    }

    private static func update(on request: Request) throws -> EventLoopFuture<Response> {
        throw Abort(.notImplemented)
    }

    private static func delete(on request: Request) throws -> EventLoopFuture<Response> {
        return try authorizeList(on: request) { identification, list throws in
            return try authorizeReservation(on: request, with: identification) { reservation in
                return try request.future(reservation)
                    .deleteModel(on: request)
                    .emitEvent("deleted for \(identification)", on: request)
                    .logMessage("deleted for \(identification)", on: request)
                    .dispatchNotification(on: request) { request, reservation in
                        list.user.get(on: request)
                            .and(
                                reservation.item.get(on: request)
                            )
                            .map { owner, item in
                                return ReservationDeleteNotification(for: owner, on: item, in: list)
                            }
                    }
                    .transform(to: success(for: list, on: request))
            }
        }
    }

    // MARK: Save

    enum SaveResult {
        case success(reservation: Reservation, item: Item)
        case failureItemReserved
    }

    /// Saves a reservation for the specified list from the request’s data.
    /// Validates the data contained in the request and
    /// creates a new reservation.
    private static func save(
        from request: Request,
        in list: List,
        for holder: Identification
    ) throws
        -> EventLoopFuture<SaveResult>
    {
        return try findItem(in: list, from: request)
            .flatMap { item in
                return try request.make(ReservationRepository.self)
                    .find(item: item.requireID())
                    .flatMap { result in
                        guard result == nil else {
                            // item already reserved (should not happen)
                            return request.future(.failureItemReserved)
                        }
                        return try save(on: item, in: list, for: holder, on: request)
                            .map { reservation in .success(reservation: reservation, item: item) }
                    }
            }
    }

    /// Saves a reservation for the specified item and list.
    private static func save(
        on item: Item,
        in list: List,
        for holder: Identification,
        on request: Request
    ) throws
        -> EventLoopFuture<Reservation>
    {
        let entity: Reservation
        // create reservation
        entity = try Reservation(item: item, holder: holder)

        return try request.make(ReservationRepository.self).save(reservation: entity)
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for list: List, on request: Request) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: redirect(for: list, on: request)
            )
        }
    }

    // MARK: - Routing

    private static func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try update(on: request)
                case .DELETE:
                    return try delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // reservation creation

        router.get("list", ID.parameter, "reservations", "create",
            use: ReservationController.renderCreateView
        )
        router.post("list", ID.parameter, "reservations",
            use: ReservationController.create
        )

        // reservation handling

        router.get("list", ID.parameter, "reservation", ID.parameter, "delete",
            use: ReservationController.renderDeleteView
        )
        router.post("list", ID.parameter, "reservation", ID.parameter,
            use: ReservationController.dispatch
        )

    }

}
