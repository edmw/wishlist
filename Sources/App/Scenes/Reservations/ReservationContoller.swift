import Vapor
import Fluent

final class ReservationController: ProtectedController, RouteCollection {

    // MARK: - VIEWS

    private static func allowView(
        on request: Request,
        _ render: @escaping (Identification, Item, List) throws -> Future<View>
    ) throws -> Future<View> {
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

    /// Renders a view to confirm the creation of a reservation.
    private static func renderCreateView(on request: Request) throws
        -> Future<View>
    {
        return try allowView(on: request) { (identification, item, list) throws in
            let context = ReservationPageContext(for: identification, and: item, in: list)
            return try renderView("Protected/ReservationCreation", with: context, on: request)
        }
    }

    /// Renders a view to confirm the deletion of a reservation.
    private static func renderDeleteView(on request: Request) throws
        -> Future<View>
    {
        return try allowView(on: request) { (identification, item, list) throws in
            return try requireReservation(on: request, for: item)
                .flatMap { reservation in
                    let context = ReservationPageContext(
                        for: identification,
                        and: item,
                        in: list,
                        with: reservation
                    )
                    return try renderView(
                        "Protected/ReservationDeletion",
                        with: context,
                        on: request
                    )
                }
        }
    }

    /// Renders a view to confirm the deletion of a reservation.
    private static func renderDeleteViewForOwner(on request: Request) throws
        -> Future<View>
    {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        return try requireReservation(on: request, for: item)
                            .flatMap { reservation in
                                let context = ReservationPageContext(
                                    for: user,
                                    and: item,
                                    in: list,
                                    with: reservation
                                )
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

    private static func authorizeList(
        on request: Request,
        _ function: @escaping (Identification, List) throws -> Future<Response>
    ) throws -> Future<Response> {

        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        // get list from request
        return try requireList(on: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        // execute the given function after authorization
                        return try function(identification, list)
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    private static func authorizeReservation(
        on request: Request,
        with identification: Identification,
        _ function: @escaping (Reservation) throws -> Future<Response>
    ) throws -> Future<Response> {

        // get reservation from request
        return try requireReservation(on: request)
            .flatMap { reservation in

                // check if the found reservation belongs to the given identification
                guard reservation.holder == identification else {
                    throw Abort(.notFound)
                }

                // execute the given function after authorization
                return try function(reservation)
            }
    }

    private static func create(on request: Request) throws -> Future<Response> {
        return try authorizeList(on: request) { (identification, list) throws in
            return try save(from: request, in: list, for: identification)
        }
    }

    private static func update(on request: Request) throws -> Future<Response> {
        throw Abort(.notImplemented)
    }

    private static func delete(on request: Request) throws -> Future<Response> {
        return try authorizeList(on: request) { (identification, list) throws in
            return try authorizeReservation(on: request, with: identification) { reservation in
                return try reservation
                    .delete(on: request)
                    .emit(
                        event: "deleted for \(identification)",
                        on: request
                    )
                    .transform(to: success(for: list, on: request))
            }
        }
    }

    /// Saves a reservation for the specified list from the request’s data.
    /// Validates the data contained in the request and
    /// creates a new reservation.
    private static func save(
        from request: Request,
        in list: List,
        for holder: Identification
    ) throws
        -> Future<Response>
    {
        return try findItem(in: list, from: request)
            .flatMap { item in
                let reservationRepository = try request.make(ReservationRepository.self)
                return try reservationRepository.find(item: item.requireID())
                    .flatMap { result in
                        guard result == nil else {
                            // item already reserved (should not happen)
                            return redirect(
                                for: list,
                                parameters: [.value(.wishAlreadyReserved, for: .message)],
                                on: request
                            )
                        }
                        let entity: Reservation
                        // create list
                        entity = try Reservation(item: item, holder: holder)

                        return try reservationRepository
                            .save(reservation: entity)
                            .emit(
                                event: "created for \(holder)",
                                on: request
                            )
                            .transform(to: success(for: list, on: request))
                    }
            }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func success(for list: List, on request: Request) -> Future<Response> {
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

    // MARK: - CRUD (Owner)

    private static func deleteForOwner(on request: Request) throws -> Future<Response> {
        let user = try requireAuthenticatedUser(on: request)

        return try requireList(on: request, for: user)
            .flatMap { list in
                return try requireItem(on: request, for: list)
                    .flatMap { item in
                        return try requireReservation(on: request, for: item)
                            .flatMap { reservation in
                                return reservation.delete(on: request).map { _ in
                                    okForOwner(for: user, and: list, on: request)
                                }
                            }
                    }
            }
    }

    // MARK: - RESULT (Owner)

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private static func okForOwner(for user: User, and list: List, on request: Request)
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

    // MARK: -

    private static func dispatch(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
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

    private static func dispatchForOwner(on request: Request) throws -> Future<Response> {
        return try method(of: request)
            .flatMap { method -> Future<Response> in
                switch method {
                case .DELETE:
                    return try deleteForOwner(on: request)
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

        router.get(
            "list", ID.parameter, "reservation", ID.parameter, "delete",
            use: ReservationController.renderDeleteView
        )
        router.post(
            "list", ID.parameter, "reservation", ID.parameter,
            use: ReservationController.dispatch
        )

        // reservation handling (for owners)

        router.get(
            "user", ID.parameter,
            "list", ID.parameter,
            "item", ID.parameter,
            "reservation", ID.parameter,
            "delete",
            use: ReservationController.renderDeleteViewForOwner
        )
        router.post(
            "user", ID.parameter,
            "list", ID.parameter,
            "item", ID.parameter,
            "reservation", ID.parameter,
            use: ReservationController.dispatchForOwner
        )

    }

    // MARK: -

    /// Returns the reservation specified by the reservation id given in the request’s route.
    /// Asumes that the reservation’s id is the next routing parameter!
    static func requireReservation(on request: Request) throws -> Future<Reservation> {
        let reservationID = try request.parameters.next(ID.self)
        return try request.make(ReservationRepository.self)
            .find(by: reservationID.uuid)
            .unwrap(or: Abort(.noContent))
    }

    /// Returns the reservation specified by the reservation id given in the request’s route.
    /// Asumes that the reservation’s id is the next routing parameter!
    static func requireReservation(
        on request: Request,
        for item: Item
    ) throws -> Future<Reservation> {
        let reservationID = try request.parameters.next(ID.self)
        return try request.make(ReservationRepository.self)
            .find(by: reservationID.uuid)
            .unwrap(or: Abort(.noContent))
            .map { reservation in
                guard reservation.itemID == item.id else {
                    throw Abort(.noContent)
                }
                return reservation
            }
    }

    /// Returns the item specified by an item id given in the request’s body or query.
    static func findItem(in list: List, from request: Request) throws -> Future<Item> {
        return request.content[ID.self, at: "itemID"]
            .flatMap { itemID in
                guard let itemID = itemID ?? request.query[.itemID] else {
                    throw Abort(.notFound)
                }
                return try request.make(ItemRepository.self)
                    .find(by: itemID.uuid, in: list)
                    .unwrap(or: Abort(.noContent))
            }
    }

}
